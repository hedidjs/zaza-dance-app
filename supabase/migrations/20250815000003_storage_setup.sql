-- Storage buckets for Zaza Dance App media files

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  (
    'profile-images',
    'profile-images',
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'gallery-media',
    'gallery-media',
    true,
    52428800, -- 50MB limit for photos and videos
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/webm']
  ),
  (
    'tutorial-videos',
    'tutorial-videos',
    true,
    104857600, -- 100MB limit for tutorial videos
    ARRAY['video/mp4', 'video/webm']
  ),
  (
    'tutorial-thumbnails',
    'tutorial-thumbnails',
    true,
    2097152, -- 2MB limit for thumbnails
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  ),
  (
    'update-images',
    'update-images',
    true,
    10485760, -- 10MB limit for update images
    ARRAY['image/jpeg', 'image/png', 'image/webp']
  );

-- Storage policies for profile images
CREATE POLICY "Anyone can view profile images" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload own profile image" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update own profile image" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own profile image" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage policies for gallery media
CREATE POLICY "Anyone can view gallery media" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery-media');

CREATE POLICY "Instructors and admins can upload gallery media" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'gallery-media' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors and admins can update gallery media" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'gallery-media' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors and admins can delete gallery media" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'gallery-media' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

-- Storage policies for tutorial videos
CREATE POLICY "Anyone can view tutorial videos" ON storage.objects
  FOR SELECT USING (bucket_id = 'tutorial-videos');

CREATE POLICY "Instructors and admins can upload tutorial videos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'tutorial-videos' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors can update own tutorial videos" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'tutorial-videos' AND
    (
      auth.uid()::text = (storage.foldername(name))[1] OR
      EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role = 'admin'
      )
    )
  );

CREATE POLICY "Instructors can delete own tutorial videos" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'tutorial-videos' AND
    (
      auth.uid()::text = (storage.foldername(name))[1] OR
      EXISTS (
        SELECT 1 FROM users 
        WHERE id = auth.uid() AND role = 'admin'
      )
    )
  );

-- Storage policies for tutorial thumbnails
CREATE POLICY "Anyone can view tutorial thumbnails" ON storage.objects
  FOR SELECT USING (bucket_id = 'tutorial-thumbnails');

CREATE POLICY "Instructors and admins can manage tutorial thumbnails" ON storage.objects
  FOR ALL USING (
    bucket_id = 'tutorial-thumbnails' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

-- Storage policies for update images
CREATE POLICY "Anyone can view update images" ON storage.objects
  FOR SELECT USING (bucket_id = 'update-images');

CREATE POLICY "Instructors and admins can manage update images" ON storage.objects
  FOR ALL USING (
    bucket_id = 'update-images' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );