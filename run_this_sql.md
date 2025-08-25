# הוראות להרצת SQL

## צעד 1: היכנס ל-Supabase Dashboard
לך ל: https://supabase.com/dashboard/project/yyvoavzgapsyycjwirmg/editor

## צעד 2: פתח את ה-SQL Editor
לחץ על "SQL Editor" בתפריט השמאלי

## צעד 3: העתק והרץ את הקוד הזה:

```sql
-- Create missing tutorial_categories table
CREATE TABLE IF NOT EXISTS tutorial_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#FF00FF',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create gallery_categories table
CREATE TABLE IF NOT EXISTS gallery_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#40E0D0',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create update_categories table
CREATE TABLE IF NOT EXISTS update_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    color VARCHAR(7) DEFAULT '#9C27B0',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE tutorial_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE update_categories ENABLE ROW LEVEL SECURITY;

-- Allow public read access to active categories
CREATE POLICY "Allow public read tutorial categories" ON tutorial_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Allow public read gallery categories" ON gallery_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Allow public read update categories" ON update_categories
    FOR SELECT USING (is_active = true);

-- Insert default data
INSERT INTO tutorial_categories (name, description, color) VALUES 
    ('התחלה', 'מדריכי ריקוד לתחילתנים', '#00FF00'),
    ('מתקדם', 'מדריכי ריקוד לרמה מתקדמת', '#FF8C00'),
    ('היפ הופ', 'מדריכי היפ הופ קלאסי', '#FF1493'),
    ('ברייקדאנס', 'מדריכי ברייקדאנס', '#8A2BE2'),
    ('ריתמי', 'תרגילי ריתם בסיסיים', '#20B2AA')
ON CONFLICT (name) DO NOTHING;

INSERT INTO gallery_categories (name, description, color) VALUES 
    ('חזרות', 'תמונות מחזרות ושיעורים', '#FF69B4'),
    ('הופעות', 'תמונות מהופעות וביצועים', '#FFD700'),
    ('אירועים', 'אירועי הסטודיו', '#32CD32'),
    ('תחרויות', 'תמונות מתחרויות', '#FF4500'),
    ('מאחורי הקלעים', 'רגעים מיוחדים מאחורי הקלעים', '#9370DB')
ON CONFLICT (name) DO NOTHING;

INSERT INTO update_categories (name, description, color) VALUES 
    ('הודעות כלליות', 'הודעות כלליות לכל הקהילה', '#4169E1'),
    ('לוח זמנים', 'שינויים בלוח זמנים ושיעורים', '#FF6347'),
    ('אירועים', 'הכרזות על אירועים מיוחדים', '#FFD700'),
    ('תחרויות', 'מידע על תחרויות', '#FF1493'),
    ('הישגים', 'הישגי התלמידים והסטודיו', '#00CED1')
ON CONFLICT (name) DO NOTHING;
```

## צעד 4: לחץ "RUN" 

אחרי שזה עובד, תגיד לי ואני אמשיך עם התיקונים בקוד Flutter! 🚀