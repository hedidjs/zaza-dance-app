-- Schema Mapping Fix - Align code expectations with existing schema

-- =============================================
-- ADD MISSING COLUMNS TO MATCH APP EXPECTATIONS
-- =============================================

-- Add missing columns to tutorials table
DO $$
BEGIN
    -- Add is_published column (using is_active as equivalent)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'is_published') THEN
        ALTER TABLE public.tutorials ADD COLUMN is_published BOOLEAN DEFAULT true;
        -- Copy is_active values to is_published for consistency
        UPDATE public.tutorials SET is_published = is_active;
    END IF;
    
    -- Add duration_minutes column (convert from duration_seconds if needed)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'duration_minutes') THEN
        ALTER TABLE public.tutorials ADD COLUMN duration_minutes INTEGER DEFAULT 0;
        -- Convert existing duration_seconds to minutes
        UPDATE public.tutorials SET duration_minutes = COALESCE(duration_seconds / 60, 0);
    END IF;
    
    -- Add category column (use category_id as string for now)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'category') THEN
        ALTER TABLE public.tutorials ADD COLUMN category TEXT DEFAULT 'general';
    END IF;
    
    -- Add instructor_id column (we'll use instructor_name for now)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'instructor_id') THEN
        ALTER TABLE public.tutorials ADD COLUMN instructor_id UUID;
    END IF;
    
    -- Add dance_style column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tutorials' AND column_name = 'dance_style') THEN
        ALTER TABLE public.tutorials ADD COLUMN dance_style TEXT;
    END IF;
END$$;

-- Add missing columns to gallery_items table
DO $$
BEGIN
    -- Add is_published column (using is_active as equivalent)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'is_published') THEN
        ALTER TABLE public.gallery_items ADD COLUMN is_published BOOLEAN DEFAULT true;
        UPDATE public.gallery_items SET is_published = is_active;
    END IF;
    
    -- Add category column (use category_id as string for now)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'category') THEN
        ALTER TABLE public.gallery_items ADD COLUMN category TEXT DEFAULT 'general';
    END IF;
    
    -- Add uploaded_by column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'uploaded_by') THEN
        ALTER TABLE public.gallery_items ADD COLUMN uploaded_by UUID;
    END IF;
    
    -- Add file_size, duration_seconds, width, height columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'file_size') THEN
        ALTER TABLE public.gallery_items ADD COLUMN file_size INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'duration_seconds') THEN
        ALTER TABLE public.gallery_items ADD COLUMN duration_seconds INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'width') THEN
        ALTER TABLE public.gallery_items ADD COLUMN width INTEGER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'gallery_items' AND column_name = 'height') THEN
        ALTER TABLE public.gallery_items ADD COLUMN height INTEGER;
    END IF;
END$$;

-- Add missing columns to updates table
DO $$
BEGIN
    -- Add summary_he column (using excerpt_he as equivalent)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'summary_he') THEN
        ALTER TABLE public.updates ADD COLUMN summary_he TEXT;
        UPDATE public.updates SET summary_he = excerpt_he;
    END IF;
    
    -- Add author_id column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'author_id') THEN
        ALTER TABLE public.updates ADD COLUMN author_id UUID;
    END IF;
    
    -- Add views_count column 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'views_count') THEN
        ALTER TABLE public.updates ADD COLUMN views_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add priority column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'priority') THEN
        ALTER TABLE public.updates ADD COLUMN priority INTEGER DEFAULT 1;
    END IF;
    
    -- Add publish_at column (using publish_date as equivalent)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'publish_at') THEN
        ALTER TABLE public.updates ADD COLUMN publish_at TIMESTAMPTZ DEFAULT NOW();
        UPDATE public.updates SET publish_at = publish_date;
    END IF;
    
    -- Add expires_at column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'updates' AND column_name = 'expires_at') THEN
        ALTER TABLE public.updates ADD COLUMN expires_at TIMESTAMPTZ;
    END IF;
END$$;

-- Create users table if it doesn't exist (since it wasn't in the schema output)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'parent', 'instructor', 'admin')),
  profile_image_url TEXT,
  bio TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create other missing tables
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

CREATE TABLE IF NOT EXISTS public.likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('tutorial', 'gallery_item', 'update')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id, content_type)
);

-- =============================================
-- CREATE INDEXES SAFELY
-- =============================================

DO $$
BEGIN
    -- Tutorials indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_published') THEN
        CREATE INDEX idx_tutorials_published ON public.tutorials(is_published);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_active') THEN
        CREATE INDEX idx_tutorials_active ON public.tutorials(is_active);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_featured') THEN
        CREATE INDEX idx_tutorials_featured ON public.tutorials(is_featured);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_difficulty') THEN
        CREATE INDEX idx_tutorials_difficulty ON public.tutorials(difficulty_level);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_category') THEN
        CREATE INDEX idx_tutorials_category ON public.tutorials(category);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_created') THEN
        CREATE INDEX idx_tutorials_created ON public.tutorials(created_at DESC);
    END IF;

    -- Gallery indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_published') THEN
        CREATE INDEX idx_gallery_published ON public.gallery_items(is_published);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_active') THEN
        CREATE INDEX idx_gallery_active ON public.gallery_items(is_active);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_category') THEN
        CREATE INDEX idx_gallery_category ON public.gallery_items(category);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_media_type') THEN
        CREATE INDEX idx_gallery_media_type ON public.gallery_items(media_type);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_created') THEN
        CREATE INDEX idx_gallery_created ON public.gallery_items(created_at DESC);
    END IF;

    -- Updates indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_active') THEN
        CREATE INDEX idx_updates_active ON public.updates(is_active);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_pinned') THEN
        CREATE INDEX idx_updates_pinned ON public.updates(is_pinned);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_type') THEN
        CREATE INDEX idx_updates_type ON public.updates(update_type);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_publish_at') THEN
        CREATE INDEX idx_updates_publish_at ON public.updates(publish_at DESC);
    END IF;

    -- Users indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role') THEN
        CREATE INDEX idx_users_role ON public.users(role);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_email') THEN
        CREATE INDEX idx_users_email ON public.users(email);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_active') THEN
        CREATE INDEX idx_users_active ON public.users(is_active);
    END IF;

    -- Other indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_progress_user') THEN
        CREATE INDEX idx_progress_user ON public.user_progress(user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_progress_tutorial') THEN
        CREATE INDEX idx_progress_tutorial ON public.user_progress(tutorial_id);
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
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_likes_content') THEN
        CREATE INDEX idx_likes_content ON public.likes(content_id, content_type);
    END IF;
END$$;

-- =============================================
-- CREATE FUNCTIONS
-- =============================================

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

-- =============================================
-- CREATE TRIGGERS
-- =============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_tutorials_updated_at') THEN
        CREATE TRIGGER update_tutorials_updated_at BEFORE UPDATE ON public.tutorials
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_gallery_items_updated_at') THEN
        CREATE TRIGGER update_gallery_items_updated_at BEFORE UPDATE ON public.gallery_items
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_updates_updated_at') THEN
        CREATE TRIGGER update_updates_updated_at BEFORE UPDATE ON public.updates
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
        CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_user_progress_updated_at') THEN
        CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON public.user_progress
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_user_preferences_updated_at') THEN
        CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END$$;

-- =============================================
-- ADD SAMPLE DATA IF TABLES ARE EMPTY
-- =============================================

DO $$
BEGIN
    -- Add sample tutorials if table is empty
    IF NOT EXISTS (SELECT 1 FROM public.tutorials LIMIT 1) THEN
        INSERT INTO public.tutorials (title_he, title_en, description_he, video_url, thumbnail_url, difficulty_level, duration_minutes, category, dance_style, is_published, is_active) VALUES
        ('ברייקדאנס למתחילים - יסודות', 'Breakdance Basics', 'לימוד הצעדים הבסיסיים בברייקדאנס', 'https://example.com/video1.mp4', 'https://example.com/thumb1.jpg', 'beginner', 15, 'tutorial', 'breakdance', true, true),
        ('פופינג מתקדם - טכניקות', 'Advanced Popping Techniques', 'טכניקות מתקדמות בפופינג', 'https://example.com/video2.mp4', 'https://example.com/thumb2.jpg', 'advanced', 25, 'tutorial', 'popping', true, true),
        ('כוריאוגרפיה לילדים', 'Kids Choreography', 'כוריאוגרפיה מהנה לילדים', 'https://example.com/video3.mp4', 'https://example.com/thumb3.jpg', 'beginner', 12, 'tutorial', 'choreography', true, true);
    END IF;

    -- Add sample gallery items if table is empty
    IF NOT EXISTS (SELECT 1 FROM public.gallery_items LIMIT 1) THEN
        INSERT INTO public.gallery_items (title_he, title_en, description_he, media_url, media_type, category, thumbnail_url, is_published, is_active) VALUES
        ('הופעת סיום 2024', 'End of Year Show 2024', 'תמונות מהופעת הסיום השנתית', 'https://example.com/gallery1.jpg', 'image', 'performances', 'https://example.com/gallery1_thumb.jpg', true, true),
        ('שיעור ברייקדאנס', 'Breakdance Class', 'מהשיעור השבועי', 'https://example.com/gallery2.jpg', 'image', 'classes', 'https://example.com/gallery2_thumb.jpg', true, true),
        ('אחורי הקלעים', 'Behind the Scenes', 'הכנות לתחרות', 'https://example.com/gallery3.mp4', 'video', 'studio_life', 'https://example.com/gallery3_thumb.jpg', true, true);
    END IF;

    -- Add sample updates if table is empty
    IF NOT EXISTS (SELECT 1 FROM public.updates LIMIT 1) THEN
        INSERT INTO public.updates (title_he, title_en, content_he, update_type, priority, is_pinned, is_active, publish_at) VALUES
        ('שיעורים מיוחדים לחופש הגדול', 'Special Summer Classes', 'אנו מתכננים שיעורי קיץ מיוחדים עם כוריאוגרפיות חדשות ומרגשות!', 'event', 2, false, true, NOW()),
        ('תחרות ריקוד שנתית', 'Annual Dance Competition', 'הצטרפו אלינו לתחרות הריקוד השנתית - פרטים נוספים בקרוב', 'important', 3, true, true, NOW()),
        ('שינוי בלוח הזמנים', 'Schedule Change', 'שיעור יום שלישי יועבר לשעה 18:00 החל מהשבוע הבא', 'schedule', 2, false, true, NOW());
    END IF;
END$$;