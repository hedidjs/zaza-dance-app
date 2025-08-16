-- Zaza Dance Database Setup Script - Safe Version
-- This script checks if tables exist before creating them

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- =============================================
-- 1. USERS TABLE (extends auth.users)
-- =============================================
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

-- =============================================
-- 2. TUTORIALS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.tutorials (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  description_he TEXT,
  description_en TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  difficulty_level TEXT NOT NULL DEFAULT 'beginner' CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  duration_minutes INTEGER NOT NULL DEFAULT 0,
  instructor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  category TEXT DEFAULT 'general',
  dance_style TEXT,
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 3. GALLERY ITEMS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.gallery_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  description_he TEXT,
  description_en TEXT,
  media_url TEXT NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  category TEXT NOT NULL DEFAULT 'general' CHECK (category IN ('classes', 'performances', 'studio_life', 'students', 'events')),
  thumbnail_url TEXT,
  file_size INTEGER,
  duration_seconds INTEGER,
  width INTEGER,
  height INTEGER,
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 4. UPDATES/NEWS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.updates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  content_he TEXT NOT NULL,
  summary_he TEXT,
  update_type TEXT NOT NULL DEFAULT 'general' CHECK (update_type IN ('general', 'event', 'important', 'schedule', 'achievement')),
  author_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  is_pinned BOOLEAN DEFAULT false,
  priority INTEGER DEFAULT 1,
  image_url TEXT,
  publish_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 5. USER PROGRESS TABLE
-- =============================================
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

-- =============================================
-- 6. ANALYTICS TABLE
-- =============================================
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

-- =============================================
-- 7. NOTIFICATIONS TABLE
-- =============================================
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

-- =============================================
-- 8. USER PREFERENCES TABLE
-- =============================================
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

-- =============================================
-- 9. LIKES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('tutorial', 'gallery_item', 'update')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id, content_type)
);

-- =============================================
-- CREATE INDEXES (only if they don't exist)
-- =============================================

DO $$
BEGIN
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

    -- Tutorials indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_tutorials_published') THEN
        CREATE INDEX idx_tutorials_published ON public.tutorials(is_published);
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
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_category') THEN
        CREATE INDEX idx_gallery_category ON public.gallery_items(category);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_gallery_created') THEN
        CREATE INDEX idx_gallery_created ON public.gallery_items(created_at DESC);
    END IF;

    -- Updates indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_active') THEN
        CREATE INDEX idx_updates_active ON public.updates(is_active);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_updates_publish') THEN
        CREATE INDEX idx_updates_publish ON public.updates(publish_at DESC);
    END IF;

    -- Other indexes
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

-- =============================================
-- CREATE FUNCTIONS (replace if exists)
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
-- CREATE TRIGGERS (only if they don't exist)
-- =============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
        CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
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
-- ENABLE ROW LEVEL SECURITY
-- =============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- =============================================
-- CREATE RLS POLICIES (drop and recreate)
-- =============================================

-- Users policies
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;
CREATE POLICY "Users can view all active users" ON public.users
    FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Tutorials policies
DROP POLICY IF EXISTS "Anyone can view published tutorials" ON public.tutorials;
CREATE POLICY "Anyone can view published tutorials" ON public.tutorials
    FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "Instructors and admins can manage tutorials" ON public.tutorials;
CREATE POLICY "Instructors and admins can manage tutorials" ON public.tutorials
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- Gallery policies
DROP POLICY IF EXISTS "Anyone can view published gallery items" ON public.gallery_items;
CREATE POLICY "Anyone can view published gallery items" ON public.gallery_items
    FOR SELECT USING (is_published = true);

DROP POLICY IF EXISTS "Instructors and admins can manage gallery" ON public.gallery_items;
CREATE POLICY "Instructors and admins can manage gallery" ON public.gallery_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- Updates policies
DROP POLICY IF EXISTS "Anyone can view active updates" ON public.updates;
CREATE POLICY "Anyone can view active updates" ON public.updates
    FOR SELECT USING (is_active = true AND publish_at <= NOW());

DROP POLICY IF EXISTS "Instructors and admins can manage updates" ON public.updates;
CREATE POLICY "Instructors and admins can manage updates" ON public.updates
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- User progress policies
DROP POLICY IF EXISTS "Users can view their own progress" ON public.user_progress;
CREATE POLICY "Users can view their own progress" ON public.user_progress
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own progress" ON public.user_progress;
CREATE POLICY "Users can insert their own progress" ON public.user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own progress" ON public.user_progress;
CREATE POLICY "Users can update their own progress" ON public.user_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Analytics policies
DROP POLICY IF EXISTS "Admins can view analytics" ON public.analytics;
CREATE POLICY "Admins can view analytics" ON public.analytics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

DROP POLICY IF EXISTS "Anyone can insert analytics" ON public.analytics;
CREATE POLICY "Anyone can insert analytics" ON public.analytics
    FOR INSERT WITH CHECK (true);

-- Notifications policies
DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can manage all notifications" ON public.notifications;
CREATE POLICY "Admins can manage all notifications" ON public.notifications
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- User preferences policies
DROP POLICY IF EXISTS "Users can manage their own preferences" ON public.user_preferences;
CREATE POLICY "Users can manage their own preferences" ON public.user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- Likes policies
DROP POLICY IF EXISTS "Users can view all likes" ON public.likes;
CREATE POLICY "Users can view all likes" ON public.likes
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can manage their own likes" ON public.likes;
CREATE POLICY "Users can manage their own likes" ON public.likes
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- INSERT SAMPLE DATA (only if tables are empty)
-- =============================================

DO $$
BEGIN
    -- Only insert if tutorials table is empty
    IF NOT EXISTS (SELECT 1 FROM public.tutorials LIMIT 1) THEN
        INSERT INTO public.tutorials (title_he, title_en, description_he, video_url, thumbnail_url, difficulty_level, duration_minutes, category, dance_style) VALUES
        ('ברייקדאנס למתחילים - יסודות', 'Breakdance Basics', 'לימוד הצעדים הבסיסיים בברייקדאנס', 'https://example.com/video1.mp4', 'https://example.com/thumb1.jpg', 'beginner', 15, 'tutorial', 'breakdance'),
        ('פופינג מתקדם - טכניקות', 'Advanced Popping Techniques', 'טכניקות מתקדמות בפופינג', 'https://example.com/video2.mp4', 'https://example.com/thumb2.jpg', 'advanced', 25, 'tutorial', 'popping'),
        ('כוריאוגרפיה לילדים', 'Kids Choreography', 'כוריאוגרפיה מהנה לילדים', 'https://example.com/video3.mp4', 'https://example.com/thumb3.jpg', 'beginner', 12, 'tutorial', 'choreography');
    END IF;

    -- Only insert if gallery_items table is empty
    IF NOT EXISTS (SELECT 1 FROM public.gallery_items LIMIT 1) THEN
        INSERT INTO public.gallery_items (title_he, description_he, media_url, media_type, category, thumbnail_url) VALUES
        ('הופעת סיום 2024', 'תמונות מהופעת הסיום השנתית', 'https://example.com/gallery1.jpg', 'image', 'performances', 'https://example.com/gallery1_thumb.jpg'),
        ('שיעור ברייקדאנס', 'מהשיעור השבועי', 'https://example.com/gallery2.jpg', 'image', 'classes', 'https://example.com/gallery2_thumb.jpg'),
        ('אחורי הקלעים', 'הכנות לתחרות', 'https://example.com/gallery3.mp4', 'video', 'studio_life', 'https://example.com/gallery3_thumb.jpg');
    END IF;

    -- Only insert if updates table is empty
    IF NOT EXISTS (SELECT 1 FROM public.updates LIMIT 1) THEN
        INSERT INTO public.updates (title_he, content_he, update_type, priority) VALUES
        ('שיעורים מיוחדים לחופש הגדול', 'אנו מתכננים שיעורי קיץ מיוחדים עם כוריאוגרפיות חדשות ומרגשות!', 'event', 2),
        ('תחרות ריקוד שנתית', 'הצטרפו אלינו לתחרות הריקוד השנתית - פרטים נוספים בקרוב', 'important', 3),
        ('שינוי בלוח הזמנים', 'שיעור יום שלישי יועבר לשעה 18:00 החל מהשבוע הבא', 'schedule', 2);
    END IF;
END$$;