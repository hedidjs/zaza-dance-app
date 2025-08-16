-- Zaza Dance Database Schema for Supabase
-- Run this SQL in your Supabase SQL editor to set up the database

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.settings.jwt_secret" = 'your-jwt-secret-here';

-- Create profiles table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    phone_number TEXT,
    address TEXT,
    role TEXT DEFAULT 'student' CHECK (role IN ('student', 'parent', 'instructor', 'admin')),
    profile_image_url TEXT,
    birth_date DATE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create storage buckets for file uploads
INSERT INTO storage.buckets (id, name, public) VALUES 
    ('profile-images', 'profile-images', true),
    ('gallery-media', 'gallery-media', true),
    ('tutorial-videos', 'tutorial-videos', true),
    ('tutorial-thumbnails', 'tutorial-thumbnails', true),
    ('update-images', 'update-images', true)
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security on profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles table
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow admins and instructors to view all profiles
CREATE POLICY "Admins and instructors can view all profiles" ON public.profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role IN ('admin', 'instructor')
        )
    );

-- Create function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role, created_at)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'student'),
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to run the function on user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER handle_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- Storage policies for profile images
CREATE POLICY "Users can upload own profile image" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profile-images' AND 
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update own profile image" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'profile-images' AND 
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete own profile image" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'profile-images' AND 
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Public read access for all gallery and tutorial content
CREATE POLICY "Public read access to gallery media" ON storage.objects
    FOR SELECT USING (bucket_id = 'gallery-media');

CREATE POLICY "Public read access to tutorial videos" ON storage.objects
    FOR SELECT USING (bucket_id = 'tutorial-videos');

CREATE POLICY "Public read access to tutorial thumbnails" ON storage.objects
    FOR SELECT USING (bucket_id = 'tutorial-thumbnails');

CREATE POLICY "Public read access to update images" ON storage.objects
    FOR SELECT USING (bucket_id = 'update-images');

-- Admin and instructor upload access for content
CREATE POLICY "Admins and instructors can upload gallery media" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'gallery-media' AND 
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role IN ('admin', 'instructor')
        )
    );

CREATE POLICY "Admins and instructors can upload tutorials" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id IN ('tutorial-videos', 'tutorial-thumbnails') AND 
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role IN ('admin', 'instructor')
        )
    );

CREATE POLICY "Admins can upload update images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'update-images' AND 
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.profiles TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS profiles_role_idx ON public.profiles(role);
CREATE INDEX IF NOT EXISTS profiles_created_at_idx ON public.profiles(created_at);
CREATE INDEX IF NOT EXISTS profiles_email_verified_idx ON public.profiles(is_email_verified);

COMMENT ON TABLE public.profiles IS 'User profiles extending Supabase auth.users';
COMMENT ON COLUMN public.profiles.role IS 'User role: student, parent, instructor, or admin';
COMMENT ON COLUMN public.profiles.metadata IS 'Additional user data as JSON';