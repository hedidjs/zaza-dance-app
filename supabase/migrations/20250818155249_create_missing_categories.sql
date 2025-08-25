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
    ('�����', '������ ����� ���������', '#00FF00'),
    ('�����', '������ ����� ���� ������', '#FF8C00'),
    ('��� ���', '������ ��� ��� �����', '#FF1493'),
    ('���������', '������ ���������', '#8A2BE2'),
    ('�����', '������ ���� �������', '#20B2AA')
ON CONFLICT (name) DO NOTHING;

INSERT INTO gallery_categories (name, description, color) VALUES 
    ('�����', '������ ������ ��������', '#FF69B4'),
    ('������', '������ ������� ��������', '#FFD700'),
    ('�������', '������ �������', '#32CD32'),
    ('�������', '������ ��������', '#FF4500'),
    ('������ ������', '����� ������� ������ ������', '#9370DB')
ON CONFLICT (name) DO NOTHING;

INSERT INTO update_categories (name, description, color) VALUES 
    ('������ ������', '������ ������ ��� ������', '#4169E1'),
    ('��� �����', '������� ���� ����� ��������', '#FF6347'),
    ('�������', '������ �� ������� �������', '#FFD700'),
    ('�������', '���� �� �������', '#FF1493'),
    ('������', '����� �������� ��������', '#00CED1')
ON CONFLICT (name) DO NOTHING;