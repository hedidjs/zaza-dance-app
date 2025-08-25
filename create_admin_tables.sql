-- יצירת טבלאות לפאנל ניהול מקצועי לאפליקציית זזה דאנס
-- Admin Panel Database Structure for Zaza Dance App

-- ==============================================
-- טבלאות קטגוריות (Categories Tables)
-- ==============================================

-- קטגוריות מדריכים
CREATE TABLE IF NOT EXISTS tutorial_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name_he TEXT NOT NULL,
  name_en TEXT,
  description_he TEXT,
  description_en TEXT,
  color_code TEXT DEFAULT '#FF00FF',
  icon_name TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- קטגוריות גלריה
CREATE TABLE IF NOT EXISTS gallery_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name_he TEXT NOT NULL,
  name_en TEXT,
  description_he TEXT,
  description_en TEXT,
  color_code TEXT DEFAULT '#00FFFF',
  icon_name TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- אלבומי גלריה
CREATE TABLE IF NOT EXISTS gallery_albums (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES gallery_categories(id) ON DELETE CASCADE,
  name_he TEXT NOT NULL,
  name_en TEXT,
  description_he TEXT,
  description_en TEXT,
  cover_image_url TEXT,
  sort_order INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- קטגוריות עדכונים
CREATE TABLE IF NOT EXISTS update_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name_he TEXT NOT NULL,
  name_en TEXT,
  description_he TEXT,
  description_en TEXT,
  color_code TEXT DEFAULT '#E91E63',
  icon_name TEXT,
  auto_publish BOOLEAN DEFAULT false,
  notification_enabled BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================
-- עדכון טבלאות קיימות (Update Existing Tables)
-- ==============================================

-- הוספת עמודות לטבלת tutorials
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES tutorial_categories(id);
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS difficulty_level TEXT DEFAULT 'beginner';
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS estimated_duration INTEGER; -- minutes
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS prerequisites TEXT[];
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS target_audience TEXT;
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);
ALTER TABLE tutorials ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- הוספת עמודות לטבלת gallery_items
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES gallery_categories(id);
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS album_id UUID REFERENCES gallery_albums(id);
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS alt_text_he TEXT;
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS alt_text_en TEXT;
ALTER TABLE gallery_items ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);

-- הוספת עמודות לטבלת updates
ALTER TABLE updates ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES update_categories(id);
ALTER TABLE updates ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft';
ALTER TABLE updates ADD COLUMN IF NOT EXISTS scheduled_publish_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE updates ADD COLUMN IF NOT EXISTS target_audience TEXT[];
ALTER TABLE updates ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);
ALTER TABLE updates ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id);
ALTER TABLE updates ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 0;

-- ==============================================
-- הרשאות RLS (Row Level Security)
-- ==============================================

-- Enable RLS on all tables
ALTER TABLE tutorial_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE update_categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for tutorial_categories
CREATE POLICY "Public can view active tutorial categories" ON tutorial_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage tutorial categories" ON tutorial_categories
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin' OR 
    auth.jwt() ->> 'role' = 'instructor'
  );

-- RLS Policies for gallery_categories
CREATE POLICY "Public can view active gallery categories" ON gallery_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage gallery categories" ON gallery_categories
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin' OR 
    auth.jwt() ->> 'role' = 'instructor'
  );

-- RLS Policies for gallery_albums
CREATE POLICY "Public can view active gallery albums" ON gallery_albums
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage gallery albums" ON gallery_albums
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin' OR 
    auth.jwt() ->> 'role' = 'instructor'
  );

-- RLS Policies for update_categories
CREATE POLICY "Public can view active update categories" ON update_categories
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage update categories" ON update_categories
  FOR ALL USING (
    auth.jwt() ->> 'role' = 'admin'
  );

-- ==============================================
-- נתונים ראשוניים (Initial Data)
-- ==============================================

-- קטגוריות מדריכים ראשוניות
INSERT INTO tutorial_categories (name_he, name_en, color_code, icon_name, sort_order) VALUES
('מתחילים', 'Beginner', '#4CAF50', 'play_circle_outline', 1),
('מתקדמים', 'Advanced', '#FF9800', 'trending_up', 2),
('מופעים', 'Performances', '#9C27B0', 'theater_comedy', 3),
('סגנונות', 'Dance Styles', '#2196F3', 'music_note', 4)
ON CONFLICT DO NOTHING;

-- קטגוריות גלריה ראשוניות
INSERT INTO gallery_categories (name_he, name_en, color_code, icon_name, sort_order) VALUES
('שיעורים', 'Classes', '#00BCD4', 'school', 1),
('מופעים', 'Performances', '#E91E63', 'stage', 2),
('אירועים', 'Events', '#FF5722', 'event', 3),
('סטודיו', 'Studio Life', '#607D8B', 'home', 4)
ON CONFLICT DO NOTHING;

-- אלבומים ראשוניים לגלריה
INSERT INTO gallery_albums (category_id, name_he, name_en, sort_order) VALUES
((SELECT id FROM gallery_categories WHERE name_he = 'שיעורים' LIMIT 1), 'שיעורי היפ הופ', 'Hip Hop Classes', 1),
((SELECT id FROM gallery_categories WHERE name_he = 'מופעים' LIMIT 1), 'מופע סוף שנה', 'End of Year Show', 1),
((SELECT id FROM gallery_categories WHERE name_he = 'אירועים' LIMIT 1), 'אירועי הסטודיו', 'Studio Events', 1)
ON CONFLICT DO NOTHING;

-- קטגוריות עדכונים ראשוניות
INSERT INTO update_categories (name_he, name_en, color_code, icon_name, notification_enabled, sort_order) VALUES
('הודעות כלליות', 'General News', '#2196F3', 'info', true, 1),
('הישגי תלמידים', 'Student Achievements', '#4CAF50', 'star', true, 2),
('אירועים חדשים', 'New Events', '#FF9800', 'event', true, 3),
('עדכוני מדריכים', 'Instructor Updates', '#9C27B0', 'person', true, 4),
('חירום', 'Emergency', '#F44336', 'warning', true, 0)
ON CONFLICT DO NOTHING;

-- ==============================================
-- פונקציות עזר (Helper Functions)
-- ==============================================

-- פונקציה לספירת פריטים בקטגוריה
CREATE OR REPLACE FUNCTION get_category_stats(category_table text, category_id_param uuid)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    result jsonb;
BEGIN
    CASE category_table
        WHEN 'tutorial_categories' THEN
            SELECT jsonb_build_object(
                'total_tutorials', count(*),
                'active_tutorials', count(*) FILTER (WHERE is_active = true),
                'featured_tutorials', count(*) FILTER (WHERE is_featured = true)
            ) INTO result
            FROM tutorials
            WHERE category_id = category_id_param;
        
        WHEN 'gallery_categories' THEN
            SELECT jsonb_build_object(
                'total_albums', count(DISTINCT ga.id),
                'total_items', count(gi.id),
                'featured_albums', count(DISTINCT ga.id) FILTER (WHERE ga.is_featured = true)
            ) INTO result
            FROM gallery_albums ga
            LEFT JOIN gallery_items gi ON ga.id = gi.album_id
            WHERE ga.category_id = category_id_param;
            
        WHEN 'update_categories' THEN
            SELECT jsonb_build_object(
                'total_updates', count(*),
                'published_updates', count(*) FILTER (WHERE status = 'published'),
                'pinned_updates', count(*) FILTER (WHERE is_pinned = true)
            ) INTO result
            FROM updates
            WHERE category_id = category_id_param;
    END CASE;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$;