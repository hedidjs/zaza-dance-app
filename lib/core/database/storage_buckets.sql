-- Supabase Storage Buckets Configuration for Zaza Dance App
-- This file sets up all the storage buckets needed for media files

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
('profile-images', 'profile-images', true),
('gallery-media', 'gallery-media', true),
('tutorial-videos', 'tutorial-videos', true),
('tutorial-thumbnails', 'tutorial-thumbnails', true),
('update-images', 'update-images', true);

-- Storage policies for public access (since this is a public dance studio app)

-- Profile images policies
CREATE POLICY "Public profile images access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'profile-images');

CREATE POLICY "Allow profile image uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'profile-images' AND (storage.foldername(name))[1] = 'profiles');

-- Gallery media policies  
CREATE POLICY "Public gallery media access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'gallery-media');

CREATE POLICY "Allow gallery media uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'gallery-media' AND (storage.foldername(name))[1] = 'gallery');

-- Tutorial videos policies
CREATE POLICY "Public tutorial videos access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'tutorial-videos');

CREATE POLICY "Allow tutorial video uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'tutorial-videos' AND (storage.foldername(name))[1] = 'tutorials');

-- Tutorial thumbnails policies
CREATE POLICY "Public tutorial thumbnails access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'tutorial-thumbnails');

CREATE POLICY "Allow tutorial thumbnail uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'tutorial-thumbnails' AND (storage.foldername(name))[1] = 'thumbnails');

-- Update images policies
CREATE POLICY "Public update images access" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'update-images');

CREATE POLICY "Allow update image uploads" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'update-images' AND (storage.foldername(name))[1] = 'updates');

-- File size limits (these would be configured in Supabase dashboard)
-- profile-images: 5MB max
-- gallery-media: 50MB max  
-- tutorial-videos: 100MB max
-- tutorial-thumbnails: 2MB max
-- update-images: 10MB max

-- MIME type restrictions (configured in Supabase dashboard)
-- profile-images: image/jpeg, image/png, image/webp
-- gallery-media: image/jpeg, image/png, image/webp, video/mp4, video/webm
-- tutorial-videos: video/mp4, video/webm, video/quicktime
-- tutorial-thumbnails: image/jpeg, image/png, image/webp
-- update-images: image/jpeg, image/png, image/webp