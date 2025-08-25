-- Create missing tutorial_categories table
CREATE TABLE IF NOT EXISTS tutorial_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#FF00FF', -- Hex color code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies for tutorial_categories
ALTER TABLE tutorial_categories ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active categories
CREATE POLICY "Allow public read of active tutorial categories" ON tutorial_categories
    FOR SELECT USING (is_active = true);

-- Allow admin full access
CREATE POLICY "Allow admin full access to tutorial categories" ON tutorial_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            JOIN user_profiles ON auth.users.id = user_profiles.user_id
            WHERE auth.users.id = auth.uid()
            AND user_profiles.role = 'admin'
        )
    );

-- Create gallery_categories table if not exists
CREATE TABLE IF NOT EXISTS gallery_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#40E0D0', -- Hex color code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies for gallery_categories
ALTER TABLE gallery_categories ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active categories
CREATE POLICY "Allow public read of active gallery categories" ON gallery_categories
    FOR SELECT USING (is_active = true);

-- Allow admin full access
CREATE POLICY "Allow admin full access to gallery categories" ON gallery_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            JOIN user_profiles ON auth.users.id = user_profiles.user_id
            WHERE auth.users.id = auth.uid()
            AND user_profiles.role = 'admin'
        )
    );

-- Create update_categories table if not exists
CREATE TABLE IF NOT EXISTS update_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#9C27B0', -- Hex color code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies for update_categories
ALTER TABLE update_categories ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active categories
CREATE POLICY "Allow public read of active update categories" ON update_categories
    FOR SELECT USING (is_active = true);

-- Allow admin full access
CREATE POLICY "Allow admin full access to update categories" ON update_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM auth.users
            JOIN user_profiles ON auth.users.id = user_profiles.user_id
            WHERE auth.users.id = auth.uid()
            AND user_profiles.role = 'admin'
        )
    );

-- Insert default categories for tutorials
INSERT INTO tutorial_categories (name, description, color) VALUES 
    ('התחלה', 'מדריכי ריקוד לתחילתנים', '#00FF00'),
    ('מתקדם', 'מדריכי ריקוד לרמה מתקדמת', '#FF8C00'),
    ('היפ הופ', 'מדריכי היפ הופ קלאסי', '#FF1493'),
    ('ברייקדאנס', 'מדריכי ברייקדאנס', '#8A2BE2'),
    ('ריתמי', 'תרגילי ריתם בסיסיים', '#20B2AA')
ON CONFLICT (name) DO NOTHING;

-- Insert default categories for gallery
INSERT INTO gallery_categories (name, description, color) VALUES 
    ('חזרות', 'תמונות מחזרות ושיעורים', '#FF69B4'),
    ('הופעות', 'תמונות מהופעות וביצועים', '#FFD700'),
    ('אירועים', 'אירועי הסטודיו', '#32CD32'),
    ('תחרויות', 'תמונות מתחרויות', '#FF4500'),
    ('מאחורי הקלעים', 'רגעים מיוחדים מאחורי הקלעים', '#9370DB')
ON CONFLICT (name) DO NOTHING;

-- Insert default categories for updates
INSERT INTO update_categories (name, description, color) VALUES 
    ('הודעות כלליות', 'הודעות כלליות לכל הקהילה', '#4169E1'),
    ('לוח זמנים', 'שינויים בלוח זמנים ושיעורים', '#FF6347'),
    ('אירועים', 'הכרזות על אירועים מיוחדים', '#FFD700'),
    ('תחרויות', 'מידע על תחרויות', '#FF1493'),
    ('הישגים', 'הישגי התלמידים והסטודיו', '#00CED1')
ON CONFLICT (name) DO NOTHING;

-- Add updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at
CREATE TRIGGER update_tutorial_categories_updated_at BEFORE UPDATE ON tutorial_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gallery_categories_updated_at BEFORE UPDATE ON gallery_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_update_categories_updated_at BEFORE UPDATE ON update_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();