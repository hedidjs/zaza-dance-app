-- Create a test user for login testing
-- First, let's check if the users table exists
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users';

-- Create users table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    phone TEXT,
    address TEXT,
    role TEXT DEFAULT 'student',
    avatar_url TEXT,
    bio TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    PRIMARY KEY (id)
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Public profiles are viewable by everyone" ON public.users
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Insert test user data if email doesn't exist
INSERT INTO public.users (id, email, display_name, phone, role, is_active)
SELECT 
    '00000000-0000-0000-0000-000000000001'::uuid,
    'hedidjs@gmail.com',
    'Test Admin User',
    '050-123-4567',
    'admin',
    true
WHERE NOT EXISTS (
    SELECT 1 FROM public.users WHERE email = 'hedidjs@gmail.com'
);
