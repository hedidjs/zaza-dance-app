-- Zaza Dance Database Setup Script
-- Run this in Supabase SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- =============================================
-- 1. USERS TABLE (extends auth.users)
-- =============================================
CREATE TABLE public.users (
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
CREATE TABLE public.tutorials (
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
  dance_style TEXT, -- breakdance, popping, choreography, etc.
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  tags TEXT[], -- Array of tags for better search
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 3. GALLERY ITEMS TABLE
-- =============================================
CREATE TABLE public.gallery_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  description_he TEXT,
  description_en TEXT,
  media_url TEXT NOT NULL,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  category TEXT NOT NULL DEFAULT 'general' CHECK (category IN ('classes', 'performances', 'studio_life', 'students', 'events')),
  thumbnail_url TEXT,
  file_size INTEGER, -- in bytes
  duration_seconds INTEGER, -- for videos
  width INTEGER, -- for images/videos
  height INTEGER, -- for images/videos
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  uploaded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  tags TEXT[], -- Array of tags
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 4. UPDATES/NEWS TABLE
-- =============================================
CREATE TABLE public.updates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  content_he TEXT NOT NULL,
  summary_he TEXT, -- Short summary for previews
  update_type TEXT NOT NULL DEFAULT 'general' CHECK (update_type IN ('general', 'event', 'important', 'schedule', 'achievement')),
  author_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  is_pinned BOOLEAN DEFAULT false, -- For important announcements
  priority INTEGER DEFAULT 1, -- 1=low, 2=medium, 3=high
  image_url TEXT,
  publish_at TIMESTAMPTZ DEFAULT NOW(), -- Schedule posts
  expires_at TIMESTAMPTZ, -- Auto-hide after date
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  tags TEXT[], -- Array of tags
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 5. USER PROGRESS TABLE
-- =============================================
CREATE TABLE public.user_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  tutorial_id UUID REFERENCES public.tutorials(id) ON DELETE CASCADE,
  watched_duration_seconds INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completion_percentage DECIMAL(5,2) DEFAULT 0.0, -- 0.00 to 100.00
  last_watched_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, tutorial_id)
);

-- =============================================
-- 6. ANALYTICS TABLE
-- =============================================
CREATE TABLE public.analytics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  event_type TEXT NOT NULL, -- 'view', 'like', 'share', 'complete', 'login', etc.
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  content_id UUID, -- Can reference tutorials, gallery_items, updates
  content_type TEXT, -- 'tutorial', 'gallery_item', 'update', 'page'
  metadata JSONB, -- Additional event data
  session_id TEXT, -- Track user sessions
  device_info JSONB, -- Device/browser info
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 7. NOTIFICATIONS TABLE
-- =============================================
CREATE TABLE public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  content_he TEXT NOT NULL,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT false,
  notification_type TEXT NOT NULL DEFAULT 'general' CHECK (notification_type IN ('general', 'tutorial', 'update', 'achievement', 'reminder')),
  action_url TEXT, -- Deep link to relevant content
  image_url TEXT,
  metadata JSONB, -- Additional notification data
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 8. USER PREFERENCES TABLE
-- =============================================
CREATE TABLE public.user_preferences (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  -- Notification preferences
  notifications_enabled BOOLEAN DEFAULT true,
  push_notifications BOOLEAN DEFAULT true,
  email_notifications BOOLEAN DEFAULT true,
  new_tutorials_notifications BOOLEAN DEFAULT true,
  gallery_updates_notifications BOOLEAN DEFAULT true,
  studio_news_notifications BOOLEAN DEFAULT true,
  class_reminders_notifications BOOLEAN DEFAULT true,
  event_notifications BOOLEAN DEFAULT true,
  message_notifications BOOLEAN DEFAULT true,
  -- Quiet hours
  quiet_hours_enabled BOOLEAN DEFAULT false,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  -- App preferences
  preferred_language TEXT DEFAULT 'he',
  auto_play_videos BOOLEAN DEFAULT false,
  video_quality TEXT DEFAULT 'auto' CHECK (video_quality IN ('auto', 'high', 'medium', 'low')),
  data_saver_mode BOOLEAN DEFAULT false,
  download_wifi_only BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 9. LIKES TABLE (for user likes)
-- =============================================
CREATE TABLE public.likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('tutorial', 'gallery_item', 'update')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id, content_type)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

-- Users indexes
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_active ON public.users(is_active);

-- Tutorials indexes
CREATE INDEX idx_tutorials_published ON public.tutorials(is_published);
CREATE INDEX idx_tutorials_featured ON public.tutorials(is_featured);
CREATE INDEX idx_tutorials_difficulty ON public.tutorials(difficulty_level);
CREATE INDEX idx_tutorials_category ON public.tutorials(category);
CREATE INDEX idx_tutorials_instructor ON public.tutorials(instructor_id);
CREATE INDEX idx_tutorials_created ON public.tutorials(created_at DESC);
CREATE INDEX idx_tutorials_views ON public.tutorials(views_count DESC);

-- Gallery indexes
CREATE INDEX idx_gallery_published ON public.gallery_items(is_published);
CREATE INDEX idx_gallery_featured ON public.gallery_items(is_featured);
CREATE INDEX idx_gallery_category ON public.gallery_items(category);
CREATE INDEX idx_gallery_type ON public.gallery_items(media_type);
CREATE INDEX idx_gallery_created ON public.gallery_items(created_at DESC);

-- Updates indexes
CREATE INDEX idx_updates_active ON public.updates(is_active);
CREATE INDEX idx_updates_pinned ON public.updates(is_pinned);
CREATE INDEX idx_updates_type ON public.updates(update_type);
CREATE INDEX idx_updates_publish ON public.updates(publish_at DESC);
CREATE INDEX idx_updates_author ON public.updates(author_id);

-- Progress indexes
CREATE INDEX idx_progress_user ON public.user_progress(user_id);
CREATE INDEX idx_progress_tutorial ON public.user_progress(tutorial_id);
CREATE INDEX idx_progress_completed ON public.user_progress(is_completed);

-- Analytics indexes
CREATE INDEX idx_analytics_event ON public.analytics(event_type);
CREATE INDEX idx_analytics_user ON public.analytics(user_id);
CREATE INDEX idx_analytics_content ON public.analytics(content_id, content_type);
CREATE INDEX idx_analytics_created ON public.analytics(created_at DESC);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_type ON public.notifications(notification_type);
CREATE INDEX idx_notifications_sent ON public.notifications(sent_at DESC);

-- Likes indexes
CREATE INDEX idx_likes_user ON public.likes(user_id);
CREATE INDEX idx_likes_content ON public.likes(content_id, content_type);

-- =============================================
-- FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tutorials_updated_at BEFORE UPDATE ON public.tutorials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gallery_items_updated_at BEFORE UPDATE ON public.gallery_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_updates_updated_at BEFORE UPDATE ON public.updates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_progress_updated_at BEFORE UPDATE ON public.user_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment view counts
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

-- Function to handle likes
CREATE OR REPLACE FUNCTION toggle_like(user_id UUID, content_id UUID, content_type TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    like_exists BOOLEAN;
BEGIN
    -- Check if like exists
    SELECT EXISTS(
        SELECT 1 FROM public.likes 
        WHERE likes.user_id = toggle_like.user_id 
        AND likes.content_id = toggle_like.content_id 
        AND likes.content_type = toggle_like.content_type
    ) INTO like_exists;

    IF like_exists THEN
        -- Remove like
        DELETE FROM public.likes 
        WHERE likes.user_id = toggle_like.user_id 
        AND likes.content_id = toggle_like.content_id 
        AND likes.content_type = toggle_like.content_type;
        
        -- Decrement likes count
        IF content_type = 'tutorial' THEN
            UPDATE public.tutorials SET likes_count = likes_count - 1 WHERE id = content_id;
        ELSIF content_type = 'gallery_item' THEN
            UPDATE public.gallery_items SET likes_count = likes_count - 1 WHERE id = content_id;
        ELSIF content_type = 'update' THEN
            UPDATE public.updates SET likes_count = likes_count - 1 WHERE id = content_id;
        END IF;
        
        RETURN FALSE; -- Like removed
    ELSE
        -- Add like
        INSERT INTO public.likes (user_id, content_id, content_type) 
        VALUES (user_id, content_id, content_type);
        
        -- Increment likes count
        IF content_type = 'tutorial' THEN
            UPDATE public.tutorials SET likes_count = likes_count + 1 WHERE id = content_id;
        ELSIF content_type = 'gallery_item' THEN
            UPDATE public.gallery_items SET likes_count = likes_count + 1 WHERE id = content_id;
        ELSIF content_type = 'update' THEN
            UPDATE public.updates SET likes_count = likes_count + 1 WHERE id = content_id;
        END IF;
        
        RETURN TRUE; -- Like added
    END IF;
END;
$$ language 'plpgsql';

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all active users" ON public.users
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Tutorials policies
CREATE POLICY "Anyone can view published tutorials" ON public.tutorials
    FOR SELECT USING (is_published = true);

CREATE POLICY "Instructors and admins can manage tutorials" ON public.tutorials
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- Gallery policies
CREATE POLICY "Anyone can view published gallery items" ON public.gallery_items
    FOR SELECT USING (is_published = true);

CREATE POLICY "Instructors and admins can manage gallery" ON public.gallery_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- Updates policies
CREATE POLICY "Anyone can view active updates" ON public.updates
    FOR SELECT USING (is_active = true AND publish_at <= NOW());

CREATE POLICY "Instructors and admins can manage updates" ON public.updates
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() 
            AND role IN ('instructor', 'admin')
        )
    );

-- User progress policies
CREATE POLICY "Users can view their own progress" ON public.user_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress" ON public.user_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON public.user_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Analytics policies (only admins can view)
CREATE POLICY "Admins can view analytics" ON public.analytics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Anyone can insert analytics" ON public.analytics
    FOR INSERT WITH CHECK (true);

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all notifications" ON public.notifications
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- User preferences policies
CREATE POLICY "Users can manage their own preferences" ON public.user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- Likes policies
CREATE POLICY "Users can view all likes" ON public.likes
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own likes" ON public.likes
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- SAMPLE DATA (Optional - for testing)
-- =============================================

-- Insert sample tutorial categories and data
INSERT INTO public.tutorials (title_he, title_en, description_he, video_url, thumbnail_url, difficulty_level, duration_minutes, category, dance_style) VALUES
('ברייקדאנס למתחילים - יסודות', 'Breakdance Basics', 'לימוד הצעדים הבסיסיים בברייקדאנס', 'https://example.com/video1.mp4', 'https://example.com/thumb1.jpg', 'beginner', 15, 'tutorial', 'breakdance'),
('פופינג מתקדם - טכניקות', 'Advanced Popping Techniques', 'טכניקות מתקדמות בפופינג', 'https://example.com/video2.mp4', 'https://example.com/thumb2.jpg', 'advanced', 25, 'tutorial', 'popping'),
('כוריאוגרפיה לילדים', 'Kids Choreography', 'כוריאוגרפיה מהנה לילדים', 'https://example.com/video3.mp4', 'https://example.com/thumb3.jpg', 'beginner', 12, 'tutorial', 'choreography');

-- Insert sample gallery items
INSERT INTO public.gallery_items (title_he, description_he, media_url, media_type, category, thumbnail_url) VALUES
('הופעת סיום 2024', 'תמונות מהופעת הסיום השנתית', 'https://example.com/gallery1.jpg', 'image', 'performances', 'https://example.com/gallery1_thumb.jpg'),
('שיעור ברייקדאנס', 'מהשיעור השבועי', 'https://example.com/gallery2.jpg', 'image', 'classes', 'https://example.com/gallery2_thumb.jpg'),
('אחורי הקלעים', 'הכנות לתחרות', 'https://example.com/gallery3.mp4', 'video', 'studio_life', 'https://example.com/gallery3_thumb.jpg');

-- Insert sample updates
INSERT INTO public.updates (title_he, content_he, update_type, priority) VALUES
('שיעורים מיוחדים לחופש הגדול', 'אנו מתכננים שיעורי קיץ מיוחדים עם כוריאוגרפיות חדשות ומרגשות!', 'event', 2),
('תחרות ריקוד שנתית', 'הצטרפו אלינו לתחרות הריקוד השנתית - פרטים נוספים בקרוב', 'important', 3),
('שינוי בלוח הזמנים', 'שיעור יום שלישי יועבר לשעה 18:00 החל מהשבוע הבא', 'schedule', 2);