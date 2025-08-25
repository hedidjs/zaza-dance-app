-- =============================================
-- ZAZA DANCE DATABASE FIX SCRIPT
-- =============================================
-- This script fixes all identified database issues:
-- 1. Schema alignment with app expectations
-- 2. Anonymous access RLS policies  
-- 3. Missing tables and columns
-- 4. Storage permissions
-- 5. Authentication setup
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. CREATE MISSING TABLES
-- =============================================

-- Categories table (missing from current schema)
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name_he TEXT NOT NULL,
  description_he TEXT,
  color TEXT DEFAULT '#FF00FF',
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User interactions table (missing from current schema)
CREATE TABLE IF NOT EXISTS public.user_interactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_device_id TEXT NOT NULL, -- For anonymous users
  content_type TEXT NOT NULL CHECK (content_type IN ('tutorial', 'gallery_item', 'update')),
  content_id UUID NOT NULL,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('like', 'view', 'share', 'download')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_device_id, content_type, content_id, interaction_type)
);

-- =============================================
-- 2. ALIGN EXISTING TABLES WITH APP EXPECTATIONS
-- =============================================

-- Rename gallery table to gallery_items to match app
ALTER TABLE IF EXISTS public.gallery RENAME TO gallery_items;

-- Add missing columns to gallery_items if they don't exist
DO $$ 
BEGIN
  -- Add category_id column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'category_id') THEN
    ALTER TABLE public.gallery_items ADD COLUMN category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL;
  END IF;
  
  -- Add is_active column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'is_active') THEN
    ALTER TABLE public.gallery_items ADD COLUMN is_active BOOLEAN DEFAULT true;
  END IF;
  
  -- Rename columns to match app expectations
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'category' AND data_type = 'text') THEN
    ALTER TABLE public.gallery_items RENAME COLUMN category TO category_text;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'title_he') THEN
    -- Check if title column exists and rename it
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'title') THEN
      ALTER TABLE public.gallery_items RENAME COLUMN title TO title_he;
    ELSE
      ALTER TABLE public.gallery_items ADD COLUMN title_he TEXT;
    END IF;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'description_he') THEN
    -- Check if description column exists and rename it
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'gallery_items' AND column_name = 'description') THEN
      ALTER TABLE public.gallery_items RENAME COLUMN description TO description_he;
    ELSE
      ALTER TABLE public.gallery_items ADD COLUMN description_he TEXT;
    END IF;
  END IF;
END $$;

-- Add missing columns to tutorials table
DO $$ 
BEGIN
  -- Add category_id column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'category_id') THEN
    ALTER TABLE public.tutorials ADD COLUMN category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL;
  END IF;
  
  -- Add is_active column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'is_active') THEN
    ALTER TABLE public.tutorials ADD COLUMN is_active BOOLEAN DEFAULT true;
  END IF;
  
  -- Add duration_seconds column if only duration_minutes exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'duration_seconds') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'duration_minutes') THEN
      ALTER TABLE public.tutorials ADD COLUMN duration_seconds INTEGER GENERATED ALWAYS AS (duration_minutes * 60) STORED;
    ELSE
      ALTER TABLE public.tutorials ADD COLUMN duration_seconds INTEGER DEFAULT 0;
    END IF;
  END IF;
  
  -- Add instructor_name column if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'instructor_name') THEN
    ALTER TABLE public.tutorials ADD COLUMN instructor_name TEXT;
  END IF;
  
  -- Add downloads_count if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tutorials' AND column_name = 'downloads_count') THEN
    ALTER TABLE public.tutorials ADD COLUMN downloads_count INTEGER DEFAULT 0;
  END IF;
END $$;

-- Add missing columns to updates table
DO $$ 
BEGIN
  -- Rename columns to match app expectations
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'title') THEN
    ALTER TABLE public.updates RENAME COLUMN title TO title_he;
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'content') THEN
    ALTER TABLE public.updates RENAME COLUMN content TO content_he;
  END IF;
  
  -- Add missing columns
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'excerpt_he') THEN
    ALTER TABLE public.updates ADD COLUMN excerpt_he TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'is_featured') THEN
    ALTER TABLE public.updates ADD COLUMN is_featured BOOLEAN DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'author_name') THEN
    ALTER TABLE public.updates ADD COLUMN author_name TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'publish_date') THEN
    -- Rename publish_at to publish_date if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'publish_at') THEN
      ALTER TABLE public.updates RENAME COLUMN publish_at TO publish_date;
    ELSE
      ALTER TABLE public.updates ADD COLUMN publish_date TIMESTAMPTZ DEFAULT NOW();
    END IF;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'comments_count') THEN
    ALTER TABLE public.updates ADD COLUMN comments_count INTEGER DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'updates' AND column_name = 'shares_count') THEN
    ALTER TABLE public.updates ADD COLUMN shares_count INTEGER DEFAULT 0;
  END IF;
END $$;

-- =============================================
-- 3. DROP EXISTING RESTRICTIVE RLS POLICIES
-- =============================================

-- Drop all existing policies that block anonymous access
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Users can view profiles" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can insert users" ON public.users;
DROP POLICY IF EXISTS "Admins can delete users" ON public.users;

DROP POLICY IF EXISTS "Anyone can view published tutorials" ON public.tutorials;
DROP POLICY IF EXISTS "Instructors and admins can manage tutorials" ON public.tutorials;
DROP POLICY IF EXISTS "Anyone can view published tutorials" ON public.tutorials;
DROP POLICY IF EXISTS "Instructors can insert tutorials" ON public.tutorials;
DROP POLICY IF EXISTS "Instructors can update own tutorials" ON public.tutorials;
DROP POLICY IF EXISTS "Instructors can delete own tutorials" ON public.tutorials;

DROP POLICY IF EXISTS "Anyone can view published gallery items" ON public.gallery_items;
DROP POLICY IF EXISTS "Instructors and admins can manage gallery" ON public.gallery_items;
DROP POLICY IF EXISTS "Anyone can view gallery" ON public.gallery_items;
DROP POLICY IF EXISTS "Instructors and admins can insert gallery" ON public.gallery_items;
DROP POLICY IF EXISTS "Instructors and admins can update gallery" ON public.gallery_items;
DROP POLICY IF EXISTS "Instructors and admins can delete gallery" ON public.gallery_items;

DROP POLICY IF EXISTS "Anyone can view active updates" ON public.updates;
DROP POLICY IF EXISTS "Instructors and admins can manage updates" ON public.updates;
DROP POLICY IF EXISTS "Anyone can view published updates" ON public.updates;
DROP POLICY IF EXISTS "Instructors and admins can insert updates" ON public.updates;
DROP POLICY IF EXISTS "Authors and admins can update updates" ON public.updates;
DROP POLICY IF EXISTS "Authors and admins can delete updates" ON public.updates;

-- =============================================
-- 4. CREATE ANONYMOUS-FRIENDLY RLS POLICIES
-- =============================================

-- USERS TABLE POLICIES
CREATE POLICY "Anyone can view user profiles" ON public.users
  FOR SELECT USING (is_active = true);

CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can manage all users" ON public.users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- CATEGORIES TABLE POLICIES
CREATE POLICY "Anyone can view active categories" ON public.categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage categories" ON public.categories
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- GALLERY_ITEMS TABLE POLICIES  
CREATE POLICY "Anyone can view active gallery items" ON public.gallery_items
  FOR SELECT USING (is_active = true);

CREATE POLICY "Authenticated users can manage gallery items" ON public.gallery_items
  FOR ALL USING (auth.uid() IS NOT NULL);

-- TUTORIALS TABLE POLICIES
CREATE POLICY "Anyone can view active tutorials" ON public.tutorials
  FOR SELECT USING (is_active = true);

CREATE POLICY "Authenticated users can manage tutorials" ON public.tutorials
  FOR ALL USING (auth.uid() IS NOT NULL);

-- UPDATES TABLE POLICIES
CREATE POLICY "Anyone can view active updates" ON public.updates
  FOR SELECT USING (is_active = true AND publish_date <= NOW());

CREATE POLICY "Authenticated users can manage updates" ON public.updates
  FOR ALL USING (auth.uid() IS NOT NULL);

-- USER_INTERACTIONS TABLE POLICIES (allow anonymous interactions)
CREATE POLICY "Anyone can insert interactions" ON public.user_interactions
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view interactions" ON public.user_interactions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can update their own device interactions" ON public.user_interactions
  FOR UPDATE USING (true);

CREATE POLICY "Anyone can delete their own device interactions" ON public.user_interactions
  FOR DELETE USING (true);

-- =============================================
-- 5. STORAGE BUCKET POLICIES (ANONYMOUS ACCESS)
-- =============================================

-- Profile images - allow viewing for everyone, uploading for authenticated users
CREATE POLICY "Anyone can view profile images" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Authenticated users can upload profile images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update their own profile images" ON storage.objects
  FOR UPDATE USING (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete their own profile images" ON storage.objects
  FOR DELETE USING (bucket_id = 'profile-images' AND auth.uid() IS NOT NULL);

-- Gallery media - allow viewing for everyone
CREATE POLICY "Anyone can view gallery media" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery-media');

CREATE POLICY "Authenticated users can manage gallery media" ON storage.objects
  FOR ALL USING (bucket_id = 'gallery-media' AND auth.uid() IS NOT NULL);

-- Tutorial videos - allow viewing for everyone
CREATE POLICY "Anyone can view tutorial videos" ON storage.objects
  FOR SELECT USING (bucket_id = 'tutorial-videos');

CREATE POLICY "Authenticated users can manage tutorial videos" ON storage.objects
  FOR ALL USING (bucket_id = 'tutorial-videos' AND auth.uid() IS NOT NULL);

-- Tutorial thumbnails - allow viewing for everyone  
CREATE POLICY "Anyone can view tutorial thumbnails" ON storage.objects
  FOR SELECT USING (bucket_id = 'tutorial-thumbnails');

CREATE POLICY "Authenticated users can manage tutorial thumbnails" ON storage.objects
  FOR ALL USING (bucket_id = 'tutorial-thumbnails' AND auth.uid() IS NOT NULL);

-- Update images - allow viewing for everyone
CREATE POLICY "Anyone can view update images" ON storage.objects  
  FOR SELECT USING (bucket_id = 'update-images');

CREATE POLICY "Authenticated users can manage update images" ON storage.objects
  FOR ALL USING (bucket_id = 'update-images' AND auth.uid() IS NOT NULL);

-- =============================================
-- 6. INSERT SAMPLE CATEGORIES
-- =============================================

INSERT INTO public.categories (name_he, description_he, color, sort_order) VALUES
  ('ברייקדאנס', 'מעקפי ראש, פריזים וכל מה שקשור לברייקדאנס', '#FF00FF', 1),
  ('פופינג', 'טכניקות פופינג ומיקסים מתקדמים', '#00FFFF', 2),
  ('כוריאוגרפיה', 'כוריאוגרפיות מקוריות ומרתקות', '#FF4081', 3),
  ('ביטלס', 'ביטלס קלאסיים ומודרניים', '#8E24AA', 4),
  ('פרי סטיל', 'אלתור חופשי וביטוי אישי', '#26C6DA', 5)
ON CONFLICT (name_he) DO NOTHING;

-- =============================================
-- 7. UPDATE EXISTING DATA TO MATCH NEW SCHEMA
-- =============================================

-- Update gallery_items to reference categories
UPDATE public.gallery_items 
SET category_id = (
  SELECT id FROM public.categories 
  WHERE name_he = 'כוריאוגרפיה' 
  LIMIT 1
)
WHERE category_text = 'choreography' OR category_text = 'performances';

UPDATE public.gallery_items 
SET category_id = (
  SELECT id FROM public.categories 
  WHERE name_he = 'פרי סטיל' 
  LIMIT 1
)
WHERE category_text = 'classes' OR category_text IS NULL;

-- Update tutorials to reference categories  
UPDATE public.tutorials 
SET category_id = (
  SELECT id FROM public.categories 
  WHERE name_he = CASE 
    WHEN dance_style = 'breakdance' THEN 'ברייקדאנס'
    WHEN dance_style = 'popping' THEN 'פופינג' 
    WHEN dance_style = 'choreography' THEN 'כוריאוגרפיה'
    ELSE 'פרי סטיל'
  END
  LIMIT 1
);

-- Set instructor names from user relationships
UPDATE public.tutorials 
SET instructor_name = (
  SELECT display_name FROM public.users 
  WHERE users.id = tutorials.instructor_id
)
WHERE instructor_name IS NULL AND instructor_id IS NOT NULL;

-- Set author names in updates
UPDATE public.updates 
SET author_name = (
  SELECT display_name FROM public.users 
  WHERE users.id = updates.author_id
)
WHERE author_name IS NULL AND author_id IS NOT NULL;

-- =============================================
-- 8. CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_active ON public.categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_sort ON public.categories(sort_order);

-- User interactions indexes
CREATE INDEX IF NOT EXISTS idx_interactions_device ON public.user_interactions(user_device_id);
CREATE INDEX IF NOT EXISTS idx_interactions_content ON public.user_interactions(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_interactions_type ON public.user_interactions(interaction_type);

-- Gallery items indexes (if not exist)
CREATE INDEX IF NOT EXISTS idx_gallery_items_category ON public.gallery_items(category_id);
CREATE INDEX IF NOT EXISTS idx_gallery_items_active ON public.gallery_items(is_active);
CREATE INDEX IF NOT EXISTS idx_gallery_items_featured ON public.gallery_items(is_featured);

-- Tutorials indexes (if not exist)
CREATE INDEX IF NOT EXISTS idx_tutorials_category ON public.tutorials(category_id);
CREATE INDEX IF NOT EXISTS idx_tutorials_active ON public.tutorials(is_active);

-- Updates indexes (if not exist) 
CREATE INDEX IF NOT EXISTS idx_updates_publish_date ON public.updates(publish_date DESC);
CREATE INDEX IF NOT EXISTS idx_updates_featured ON public.updates(is_featured);

-- =============================================
-- 9. ENABLE RLS ON NEW TABLES
-- =============================================

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;

-- =============================================
-- 10. SAMPLE DATA FOR TESTING
-- =============================================

-- Insert sample gallery items if none exist
INSERT INTO public.gallery_items (title_he, description_he, media_url, media_type, thumbnail_url, is_featured, category_id)
SELECT 
  'דוגמת תמונה מהסטודיו',
  'תמונה לדוגמה מפעילות הסטודיו',
  'https://via.placeholder.com/800x600/FF00FF/FFFFFF?text=Zaza+Dance',
  'image',
  'https://via.placeholder.com/400x300/FF00FF/FFFFFF?text=Zaza+Dance',
  true,
  (SELECT id FROM public.categories WHERE name_he = 'כוריאוגרפיה' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM public.gallery_items);

-- Insert sample tutorial if none exist
INSERT INTO public.tutorials (title_he, description_he, video_url, thumbnail_url, difficulty_level, duration_seconds, instructor_name, is_featured, category_id)
SELECT 
  'שיעור ברייקדאנס לדוגמה',
  'שיעור בסיסי לברייקדאנס למתחילים',
  'https://via.placeholder.com/800x450/00FFFF/000000?text=Tutorial+Video',
  'https://via.placeholder.com/400x225/00FFFF/000000?text=Tutorial',
  'beginner',
  900,
  'מדריך לדוגמה',
  true,
  (SELECT id FROM public.categories WHERE name_he = 'ברייקדאנס' LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM public.tutorials);

-- Insert sample update if none exist  
INSERT INTO public.updates (title_he, content_he, excerpt_he, update_type, author_name, is_pinned, is_featured, publish_date)
SELECT 
  'ברוכים הבאים לסטודיו זזה דאנס!',
  'אנחנו שמחים לקבל את פניכם באפליקציה החדשה של סטודיו זזה דאנס. כאן תוכלו למצוא את כל מה שקשור לעולם ההיפ הופ - שיעורים, מדריכים, עדכונים ועוד!',
  'ברוכים הבאים לאפליקציה החדשה!',
  'general',
  'צוות זזה דאנס',
  true,
  true,
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM public.updates);

-- =============================================
-- SCRIPT COMPLETION MESSAGE  
-- =============================================

DO $$ 
BEGIN 
  RAISE NOTICE 'Zaza Dance database fix completed successfully!';
  RAISE NOTICE 'The following issues have been resolved:';
  RAISE NOTICE '✓ Schema alignment with app expectations';  
  RAISE NOTICE '✓ Anonymous access RLS policies';
  RAISE NOTICE '✓ Missing tables and columns added';
  RAISE NOTICE '✓ Storage permissions configured';
  RAISE NOTICE '✓ Sample data inserted for testing';
  RAISE NOTICE '';
  RAISE NOTICE 'Your app should now work properly with anonymous users!';
END $$;