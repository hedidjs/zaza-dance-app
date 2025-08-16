-- Schema Migration Script - Add missing columns to existing tables

-- =============================================
-- ADD MISSING COLUMNS TO EXISTING TABLES
-- =============================================

-- Add missing columns to tutorials table if they don't exist
DO $$
BEGIN
    -- Add is_published column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'is_published') THEN
        ALTER TABLE public.tutorials ADD COLUMN is_published BOOLEAN DEFAULT true;
    END IF;
    
    -- Add views_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'views_count') THEN
        ALTER TABLE public.tutorials ADD COLUMN views_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add likes_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'likes_count') THEN
        ALTER TABLE public.tutorials ADD COLUMN likes_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add is_featured column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'is_featured') THEN
        ALTER TABLE public.tutorials ADD COLUMN is_featured BOOLEAN DEFAULT false;
    END IF;
    
    -- Add tags column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'tags') THEN
        ALTER TABLE public.tutorials ADD COLUMN tags TEXT[];
    END IF;
    
    -- Add instructor_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'instructor_id') THEN
        ALTER TABLE public.tutorials ADD COLUMN instructor_id UUID REFERENCES public.users(id) ON DELETE SET NULL;
    END IF;
    
    -- Add dance_style column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'dance_style') THEN
        ALTER TABLE public.tutorials ADD COLUMN dance_style TEXT;
    END IF;
END$$;

-- Add missing columns to gallery_items table if they don't exist
DO $$
BEGIN
    -- Add is_published column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'is_published') THEN
        ALTER TABLE public.gallery_items ADD COLUMN is_published BOOLEAN DEFAULT true;
    END IF;
    
    -- Add views_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'views_count') THEN
        ALTER TABLE public.gallery_items ADD COLUMN views_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add likes_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'likes_count') THEN
        ALTER TABLE public.gallery_items ADD COLUMN likes_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add is_featured column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'is_featured') THEN
        ALTER TABLE public.gallery_items ADD COLUMN is_featured BOOLEAN DEFAULT false;
    END IF;
    
    -- Add tags column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'tags') THEN
        ALTER TABLE public.gallery_items ADD COLUMN tags TEXT[];
    END IF;
    
    -- Add uploaded_by column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'uploaded_by') THEN
        ALTER TABLE public.gallery_items ADD COLUMN uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL;
    END IF;
    
    -- Add file_size column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'file_size') THEN
        ALTER TABLE public.gallery_items ADD COLUMN file_size INTEGER;
    END IF;
    
    -- Add duration_seconds column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'duration_seconds') THEN
        ALTER TABLE public.gallery_items ADD COLUMN duration_seconds INTEGER;
    END IF;
    
    -- Add width column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'width') THEN
        ALTER TABLE public.gallery_items ADD COLUMN width INTEGER;
    END IF;
    
    -- Add height column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'height') THEN
        ALTER TABLE public.gallery_items ADD COLUMN height INTEGER;
    END IF;
END$$;

-- Add missing columns to updates table if they don't exist
DO $$
BEGIN
    -- Add is_active column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'is_active') THEN
        ALTER TABLE public.updates ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    -- Add views_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'views_count') THEN
        ALTER TABLE public.updates ADD COLUMN views_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add likes_count column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'likes_count') THEN
        ALTER TABLE public.updates ADD COLUMN likes_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add is_pinned column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'is_pinned') THEN
        ALTER TABLE public.updates ADD COLUMN is_pinned BOOLEAN DEFAULT false;
    END IF;
    
    -- Add tags column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'tags') THEN
        ALTER TABLE public.updates ADD COLUMN tags TEXT[];
    END IF;
    
    -- Add author_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'author_id') THEN
        ALTER TABLE public.updates ADD COLUMN author_id UUID REFERENCES public.users(id) ON DELETE SET NULL;
    END IF;
    
    -- Add summary_he column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'summary_he') THEN
        ALTER TABLE public.updates ADD COLUMN summary_he TEXT;
    END IF;
    
    -- Add image_url column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'image_url') THEN
        ALTER TABLE public.updates ADD COLUMN image_url TEXT;
    END IF;
    
    -- Add publish_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'publish_at') THEN
        ALTER TABLE public.updates ADD COLUMN publish_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
    
    -- Add expires_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'expires_at') THEN
        ALTER TABLE public.updates ADD COLUMN expires_at TIMESTAMPTZ;
    END IF;
END$$;

-- Add missing columns to users table if they don't exist
DO $$
BEGIN
    -- Add is_active column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'is_active') THEN
        ALTER TABLE public.users ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
    
    -- Add bio column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'bio') THEN
        ALTER TABLE public.users ADD COLUMN bio TEXT;
    END IF;
    
    -- Add profile_image_url column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'profile_image_url') THEN
        ALTER TABLE public.users ADD COLUMN profile_image_url TEXT;
    END IF;
END$$;

-- =============================================
-- CREATE MISSING TABLES
-- =============================================

-- Create user_progress table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  tutorial_id UUID REFERENCES public.tutorials(id) ON DELETE CASCADE,
  watched_duration_seconds INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completion_percentage DECIMAL(5,2) DEFAULT 0.0,
  last_watched_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, tutorial_id)
);

-- Create analytics table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.analytics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  event_type TEXT NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  content_id UUID,
  content_type TEXT,
  metadata JSONB,
  session_id TEXT,
  device_info JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create notifications table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  content_he TEXT NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT false,
  notification_type TEXT NOT NULL DEFAULT 'general' CHECK (notification_type IN ('general', 'tutorial', 'update', 'achievement', 'reminder')),
  action_url TEXT,
  image_url TEXT,
  metadata JSONB,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_preferences table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_preferences (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  notifications_enabled BOOLEAN DEFAULT true,
  push_notifications BOOLEAN DEFAULT true,
  email_notifications BOOLEAN DEFAULT true,
  new_tutorials_notifications BOOLEAN DEFAULT true,
  gallery_updates_notifications BOOLEAN DEFAULT true,
  studio_news_notifications BOOLEAN DEFAULT true,
  class_reminders_notifications BOOLEAN DEFAULT true,
  event_notifications BOOLEAN DEFAULT true,
  message_notifications BOOLEAN DEFAULT true,
  quiet_hours_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  preferred_language TEXT DEFAULT 'he',
  auto_play_videos BOOLEAN DEFAULT false,
  video_quality TEXT DEFAULT 'auto' CHECK (video_quality IN ('auto', 'high', 'medium', 'low')),
  data_saver_mode BOOLEAN DEFAULT false,
  download_wifi_only BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create likes table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('tutorial', 'gallery_item', 'update')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id, content_type)
);

-- =============================================
-- NOW CREATE THE INDEXES SAFELY
-- =============================================

DO $$
BEGIN
    -- Check if column exists before creating index
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'tutorials' AND column_name = 'is_published') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_published') THEN
            CREATE INDEX idx_tutorials_published ON public.tutorials(is_published);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'tutorials' AND column_name = 'is_featured') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_featured') THEN
            CREATE INDEX idx_tutorials_featured ON public.tutorials(is_featured);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'tutorials' AND column_name = 'difficulty_level') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_difficulty') THEN
            CREATE INDEX idx_tutorials_difficulty ON public.tutorials(difficulty_level);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'tutorials' AND column_name = 'category') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_category') THEN
            CREATE INDEX idx_tutorials_category ON public.tutorials(category);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'tutorials' AND column_name = 'created_at') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_created') THEN
            CREATE INDEX idx_tutorials_created ON public.tutorials(created_at DESC);
        END IF;
    END IF;
    
    -- Users indexes
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'users' AND column_name = 'role') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role') THEN
            CREATE INDEX idx_users_role ON public.users(role);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'users' AND column_name = 'is_active') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_active') THEN
            CREATE INDEX idx_users_active ON public.users(is_active);
        END IF;
    END IF;
    
    -- Gallery indexes
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'gallery_items' AND column_name = 'is_published') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_published') THEN
            CREATE INDEX idx_gallery_published ON public.gallery_items(is_published);
        END IF;
    END IF;
    
    -- Updates indexes
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'updates' AND column_name = 'is_active') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_active') THEN
            CREATE INDEX idx_updates_active ON public.updates(is_active);
        END IF;
    END IF;
    
    -- Basic indexes that should always work
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_progress_user') THEN
        CREATE INDEX idx_progress_user ON public.user_progress(user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_analytics_created') THEN
        CREATE INDEX idx_analytics_created ON public.analytics(created_at DESC);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notifications_user') THEN
        CREATE INDEX idx_notifications_user ON public.notifications(user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_likes_user') THEN
        CREATE INDEX idx_likes_user ON public.likes(user_id);
    END IF;
END$$;

-- Create the functions and everything else from the previous script
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION increment_view_count(content_table TEXT, content_id UUID)
RETURNS VOID AS $$
BEGIN
    IF content_table = 'tutorials' THEN
        UPDATE public.tutorials SET views_count = views_count + 1 WHERE id = content_id;
    ELSIF content_table = 'gallery_items' THEN
        UPDATE public.gallery_items SET views_count = views_count + 1 WHERE id = content_id;
    ELSIF content_table = 'updates' THEN
        UPDATE public.updates SET views_count = views_count + 1 WHERE id = content_id;
    END IF;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION toggle_like(user_id UUID, content_id UUID, content_type TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    like_exists BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM public.likes 
        WHERE likes.user_id = toggle_like.user_id 
        AND likes.content_id = toggle_like.content_id 
        AND likes.content_type = toggle_like.content_type
    ) INTO like_exists;

    IF like_exists THEN
        DELETE FROM public.likes 
        WHERE likes.user_id = toggle_like.user_id 
        AND likes.content_id = toggle_like.content_id 
        AND likes.content_type = toggle_like.content_type;
        
        IF content_type = 'tutorial' THEN
            UPDATE public.tutorials SET likes_count = likes_count - 1 WHERE id = content_id;
        ELSIF content_type = 'gallery_item' THEN
            UPDATE public.gallery_items SET likes_count = likes_count - 1 WHERE id = content_id;
        ELSIF content_type = 'update' THEN
            UPDATE public.updates SET likes_count = likes_count - 1 WHERE id = content_id;
        END IF;
        
        RETURN FALSE;
    ELSE
        INSERT INTO public.likes (user_id, content_id, content_type) 
        VALUES (user_id, content_id, content_type);
        
        IF content_type = 'tutorial' THEN
            UPDATE public.tutorials SET likes_count = likes_count + 1 WHERE id = content_id;
        ELSIF content_type = 'gallery_item' THEN
            UPDATE public.gallery_items SET likes_count = likes_count + 1 WHERE id = content_id;
        ELSIF content_type = 'update' THEN
            UPDATE public.updates SET likes_count = likes_count + 1 WHERE id = content_id;
        END IF;
        
        RETURN TRUE;
    END IF;
END;
$$ language 'plpgsql';