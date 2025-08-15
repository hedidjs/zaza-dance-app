-- Supabase Database Schema for Zaza Dance App
-- This file contains the complete database structure for the hip-hop dance studio app

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row Level Security
ALTER DATABASE postgres SET "app.settings.jwt_secret" = 'your-jwt-secret-here';

-- Categories table for organizing content
CREATE TABLE categories (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name_he TEXT NOT NULL,
  name_en TEXT,
  description_he TEXT,
  description_en TEXT,
  color TEXT DEFAULT '#FF00FF',
  icon TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Gallery items table
CREATE TABLE gallery_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  description_he TEXT,
  description_en TEXT,
  media_url TEXT NOT NULL,
  thumbnail_url TEXT,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  category_id UUID REFERENCES categories(id),
  tags TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tutorials table
CREATE TABLE tutorials (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  description_he TEXT,
  description_en TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration_seconds INTEGER,
  difficulty_level TEXT CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  category_id UUID REFERENCES categories(id),
  instructor_name TEXT,
  tags TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT false,
  likes_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  downloads_count INTEGER DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Updates/News table
CREATE TABLE updates (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title_he TEXT NOT NULL,
  title_en TEXT,
  content_he TEXT NOT NULL,
  content_en TEXT,
  excerpt_he TEXT,
  excerpt_en TEXT,
  image_url TEXT,
  update_type TEXT NOT NULL CHECK (update_type IN ('news', 'announcement', 'event', 'achievement', 'tip')),
  is_pinned BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  author_name TEXT,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  shares_count INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  publish_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User interactions tracking (likes, views, etc.)
CREATE TABLE user_interactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_device_id TEXT NOT NULL, -- Since we don't have user authentication, use device ID
  content_type TEXT NOT NULL CHECK (content_type IN ('gallery_item', 'tutorial', 'update')),
  content_id UUID NOT NULL,
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('like', 'view', 'share', 'download')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_device_id, content_type, content_id, interaction_type)
);

-- Indexes for better performance
CREATE INDEX idx_gallery_items_category ON gallery_items(category_id);
CREATE INDEX idx_gallery_items_featured ON gallery_items(is_featured) WHERE is_featured = true;
CREATE INDEX idx_gallery_items_active ON gallery_items(is_active) WHERE is_active = true;
CREATE INDEX idx_gallery_items_created ON gallery_items(created_at DESC);

CREATE INDEX idx_tutorials_category ON tutorials(category_id);
CREATE INDEX idx_tutorials_featured ON tutorials(is_featured) WHERE is_featured = true;
CREATE INDEX idx_tutorials_difficulty ON tutorials(difficulty_level);
CREATE INDEX idx_tutorials_active ON tutorials(is_active) WHERE is_active = true;
CREATE INDEX idx_tutorials_created ON tutorials(created_at DESC);

CREATE INDEX idx_updates_type ON updates(update_type);
CREATE INDEX idx_updates_pinned ON updates(is_pinned) WHERE is_pinned = true;
CREATE INDEX idx_updates_featured ON updates(is_featured) WHERE is_featured = true;
CREATE INDEX idx_updates_publish ON updates(publish_date DESC);
CREATE INDEX idx_updates_active ON updates(is_active) WHERE is_active = true;

CREATE INDEX idx_user_interactions_device ON user_interactions(user_device_id);
CREATE INDEX idx_user_interactions_content ON user_interactions(content_type, content_id);

-- Functions to update counts
CREATE OR REPLACE FUNCTION update_gallery_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.interaction_type = 'like' AND NEW.content_type = 'gallery_item' THEN
    UPDATE gallery_items 
    SET likes_count = likes_count + 1 
    WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' AND OLD.interaction_type = 'like' AND OLD.content_type = 'gallery_item' THEN
    UPDATE gallery_items 
    SET likes_count = likes_count - 1 
    WHERE id = OLD.content_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_tutorial_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.content_type = 'tutorial' THEN
    CASE NEW.interaction_type
      WHEN 'like' THEN
        UPDATE tutorials SET likes_count = likes_count + 1 WHERE id = NEW.content_id;
      WHEN 'view' THEN
        UPDATE tutorials SET views_count = views_count + 1 WHERE id = NEW.content_id;
      WHEN 'download' THEN
        UPDATE tutorials SET downloads_count = downloads_count + 1 WHERE id = NEW.content_id;
    END CASE;
  ELSIF TG_OP = 'DELETE' AND OLD.content_type = 'tutorial' THEN
    CASE OLD.interaction_type
      WHEN 'like' THEN
        UPDATE tutorials SET likes_count = likes_count - 1 WHERE id = OLD.content_id;
      WHEN 'view' THEN
        UPDATE tutorials SET views_count = views_count - 1 WHERE id = OLD.content_id;
      WHEN 'download' THEN
        UPDATE tutorials SET downloads_count = downloads_count - 1 WHERE id = OLD.content_id;
    END CASE;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_update_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.interaction_type = 'like' AND NEW.content_type = 'update' THEN
    UPDATE updates 
    SET likes_count = likes_count + 1 
    WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' AND OLD.interaction_type = 'like' AND OLD.content_type = 'update' THEN
    UPDATE updates 
    SET likes_count = likes_count - 1 
    WHERE id = OLD.content_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trigger_gallery_likes
  AFTER INSERT OR DELETE ON user_interactions
  FOR EACH ROW
  EXECUTE FUNCTION update_gallery_likes_count();

CREATE TRIGGER trigger_tutorial_counts
  AFTER INSERT OR DELETE ON user_interactions
  FOR EACH ROW
  EXECUTE FUNCTION update_tutorial_counts();

CREATE TRIGGER trigger_update_likes
  AFTER INSERT OR DELETE ON user_interactions
  FOR EACH ROW
  EXECUTE FUNCTION update_update_likes_count();

-- Updated at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_categories_updated_at 
  BEFORE UPDATE ON categories 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gallery_items_updated_at 
  BEFORE UPDATE ON gallery_items 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tutorials_updated_at 
  BEFORE UPDATE ON tutorials 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_updates_updated_at 
  BEFORE UPDATE ON updates 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies - since this is a public app, allow read access to all
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_interactions ENABLE ROW LEVEL SECURITY;

-- Allow public read access to all content
CREATE POLICY "Allow public read access" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON gallery_items FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access" ON tutorials FOR SELECT USING (is_active = true);
CREATE POLICY "Allow public read access" ON updates FOR SELECT USING (is_active = true);

-- Allow anyone to track interactions (for analytics)
CREATE POLICY "Allow public interaction tracking" ON user_interactions 
  FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public interaction read" ON user_interactions 
  FOR SELECT USING (true);
CREATE POLICY "Allow public interaction delete" ON user_interactions 
  FOR DELETE USING (true);

-- Insert sample categories
INSERT INTO categories (name_he, name_en, description_he, color, sort_order) VALUES
('היפ הופ קלאסי', 'Classic Hip Hop', 'תנועות בסיסיות וקלאסיות של היפ הופ', '#FF00FF', 1),
('ברייקדאנס', 'Breakdancing', 'תנועות קרקע ואקרובטיות', '#40E0D0', 2),
('פופינג', 'Popping', 'תנועות פופינג ולוקינג', '#9C27B0', 3),
('הופ הופ מודרני', 'Modern Hip Hop', 'סגנונות חדשים ומעורבים', '#E91E63', 4),
('אירועים', 'Events', 'תחרויות והופעות', '#FF5722', 5),
('הישגים', 'Achievements', 'הישגי תלמידים', '#4CAF50', 6);

-- Sample gallery items
INSERT INTO gallery_items (title_he, description_he, media_url, thumbnail_url, media_type, category_id, is_featured, tags) VALUES
('ביצוע מדהים של מיה', 'מיה מבצעת רצף ברייקדאנס מושלם', 'https://example.com/video1.mp4', 'https://example.com/thumb1.jpg', 'video', (SELECT id FROM categories WHERE name_he = 'ברייקדאנס'), true, ARRAY['ברייקדאנס', 'תלמידים', 'ביצוע']),
('סשן אימון קבוצתי', 'האימון השבועי של הקבוצה המתקדמת', 'https://example.com/video2.mp4', 'https://example.com/thumb2.jpg', 'video', (SELECT id FROM categories WHERE name_he = 'היפ הופ קלאסי'), false, ARRAY['קבוצתי', 'אימון']),
('תמונת הקבוצה', 'תמונה משותפת אחרי התחרות', 'https://example.com/image1.jpg', 'https://example.com/image1.jpg', 'image', (SELECT id FROM categories WHERE name_he = 'אירועים'), true, ARRAY['קבוצה', 'תחרות']);

-- Sample tutorials
INSERT INTO tutorials (title_he, description_he, video_url, thumbnail_url, duration_seconds, difficulty_level, category_id, instructor_name, is_featured, tags) VALUES
('יסודות הברייקדאנס למתחילים', 'למד את התנועות הבסיסיות של ברייקדאנס', 'https://example.com/tutorial1.mp4', 'https://example.com/tutorial_thumb1.jpg', 900, 'beginner', (SELECT id FROM categories WHERE name_he = 'ברייקדאנס'), 'רועי המדריך', true, ARRAY['למתחילים', 'יסודות']),
('פופינג מתקדם', 'טכניקות מתקדמות בפופינג', 'https://example.com/tutorial2.mp4', 'https://example.com/tutorial_thumb2.jpg', 1200, 'advanced', (SELECT id FROM categories WHERE name_he = 'פופינג'), 'שרון המדריכה', false, ARRAY['מתקדם', 'טכניקות']),
('היפ הופ לילדים', 'מדריך מיוחד לילדים צעירים', 'https://example.com/tutorial3.mp4', 'https://example.com/tutorial_thumb3.jpg', 600, 'beginner', (SELECT id FROM categories WHERE name_he = 'היפ הופ קלאסי'), 'דני המדריך', true, ARRAY['ילדים', 'כיף']);

-- Sample updates/news
INSERT INTO updates (title_he, content_he, excerpt_he, image_url, update_type, is_pinned, author_name, tags) VALUES
('🔥 תחרות ההיפ הופ השנתית!', 'אנחנו גאים להודיע על תחרות ההיפ הופ השנתית שלנו! התחרות תתקיים בחודש הבא ופתוחה לכל הרמות. פרסים מדהימים מחכים לזוכים!', 'תחרות ההיפ הופ השנתית - הרשמה פתוחה!', 'https://example.com/competition.jpg', 'announcement', true, 'צוות זזה דאנס', ARRAY['תחרות', 'הודעה']),
('⭐ מיה זוכה במקום הראשון!', 'התלמידה שלנו מיה זכתה במקום הראשון בתחרות הארצית! אנחנו כל כך גאים בה ובהישג המדהים הזה. מיה מראה לנו שבעבודה קשה ומסירות אפשר להגיע לכל מקום!', 'מיה מככבת בתחרות הארצית', 'https://example.com/mia_winner.jpg', 'achievement', false, 'רועי המדריך', ARRAY['הישג', 'תלמידים']),
('💡 טיפ השבוע: שיפור הקצב', 'השבוע נלמד איך לשפר את הקצב שלנו בריקוד. הסוד הוא להקשיב למוזיקה באמת ולהרגיש אותה בגוף. תתרגלו עם מטרונום ותבחינו בשיפור!', 'טיפים לשיפור הקצב בריקוד', 'https://example.com/rhythm_tip.jpg', 'tip', false, 'שרון המדריכה', ARRAY['טיפים', 'קצב']);

-- Sample user interactions (using device IDs)
INSERT INTO user_interactions (user_device_id, content_type, content_id, interaction_type) VALUES
('device_123', 'gallery_item', (SELECT id FROM gallery_items LIMIT 1), 'like'),
('device_456', 'tutorial', (SELECT id FROM tutorials LIMIT 1), 'view'),
('device_789', 'update', (SELECT id FROM updates LIMIT 1), 'like');