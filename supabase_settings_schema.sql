-- Zaza Dance App - Settings Database Schema
-- הגדרות התראות למשתמשים

CREATE TABLE IF NOT EXISTS user_notification_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- הגדרות התראות כלליות
    push_notifications_enabled BOOLEAN DEFAULT true NOT NULL,
    
    -- סוגי התראות
    new_tutorials_notifications BOOLEAN DEFAULT true NOT NULL,
    gallery_updates_notifications BOOLEAN DEFAULT true NOT NULL,
    studio_news_notifications BOOLEAN DEFAULT true NOT NULL,
    class_reminders_notifications BOOLEAN DEFAULT true NOT NULL,
    event_notifications BOOLEAN DEFAULT true NOT NULL,
    message_notifications BOOLEAN DEFAULT true NOT NULL,
    
    -- שעות שקט
    quiet_hours_enabled BOOLEAN DEFAULT false NOT NULL,
    quiet_hours_start TEXT DEFAULT '22:00' NOT NULL,
    quiet_hours_end TEXT DEFAULT '08:00' NOT NULL,
    
    -- תדירות תזכורות
    reminder_frequency TEXT DEFAULT 'daily' NOT NULL CHECK (reminder_frequency IN ('daily', 'weekly', 'never')),
    
    -- מטא-דאטה
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(user_id)
);

-- הגדרות כלליות למשתמשים
CREATE TABLE IF NOT EXISTS user_general_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- הגדרות תצוגה
    font_size NUMERIC(4,2) DEFAULT 16.0 NOT NULL CHECK (font_size >= 12.0 AND font_size <= 24.0),
    animations_enabled BOOLEAN DEFAULT true NOT NULL,
    neon_effects_enabled BOOLEAN DEFAULT true NOT NULL,
    
    -- הגדרות וידאו וביצועים
    video_quality TEXT DEFAULT 'auto' NOT NULL CHECK (video_quality IN ('auto', 'high', 'medium', 'low')),
    autoplay_videos BOOLEAN DEFAULT false NOT NULL,
    data_saver_mode BOOLEAN DEFAULT false NOT NULL,
    download_wifi_only BOOLEAN DEFAULT true NOT NULL,
    
    -- הגדרות נגישות
    high_contrast_mode BOOLEAN DEFAULT false NOT NULL,
    reduced_motion BOOLEAN DEFAULT false NOT NULL,
    screen_reader_support BOOLEAN DEFAULT false NOT NULL,
    button_size NUMERIC(3,2) DEFAULT 1.0 NOT NULL CHECK (button_size >= 0.8 AND button_size <= 1.4),
    
    -- הגדרות פרטיות ונתונים
    analytics_enabled BOOLEAN DEFAULT true NOT NULL,
    crash_reports_enabled BOOLEAN DEFAULT true NOT NULL,
    personalized_content BOOLEAN DEFAULT true NOT NULL,
    
    -- מטא-דאטה
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    
    UNIQUE(user_id)
);

-- אינדקסים לביצועים
CREATE INDEX IF NOT EXISTS idx_user_notification_settings_user_id ON user_notification_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_general_settings_user_id ON user_general_settings(user_id);

-- פונקציות עדכון אוטומטי של updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- טריגרים לעדכון אוטומטי
DROP TRIGGER IF EXISTS update_user_notification_settings_updated_at ON user_notification_settings;
CREATE TRIGGER update_user_notification_settings_updated_at
    BEFORE UPDATE ON user_notification_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_general_settings_updated_at ON user_general_settings;
CREATE TRIGGER update_user_general_settings_updated_at
    BEFORE UPDATE ON user_general_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- מדיניות אבטחה (RLS - Row Level Security)
ALTER TABLE user_notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_general_settings ENABLE ROW LEVEL SECURITY;

-- מדיניות גישה - משתמשים יכולים לגשת רק להגדרות שלהם
CREATE POLICY "Users can view their own notification settings" ON user_notification_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notification settings" ON user_notification_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notification settings" ON user_notification_settings
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notification settings" ON user_notification_settings
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own general settings" ON user_general_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own general settings" ON user_general_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own general settings" ON user_general_settings
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own general settings" ON user_general_settings
    FOR DELETE USING (auth.uid() = user_id);

-- הוספת הערות לטבלאות
COMMENT ON TABLE user_notification_settings IS 'הגדרות התראות עבור משתמשי אפליקציית זזה דאנס';
COMMENT ON TABLE user_general_settings IS 'הגדרות כלליות עבור משתמשי אפליקציית זזה דאנס';

-- הוספת הערות לעמודות חשובות
COMMENT ON COLUMN user_notification_settings.reminder_frequency IS 'תדירות תזכורות שיעורים: daily, weekly, never';
COMMENT ON COLUMN user_general_settings.video_quality IS 'איכות וידאו: auto, high, medium, low';
COMMENT ON COLUMN user_general_settings.font_size IS 'גודל טקסט באפליקציה (12.0-24.0)';
COMMENT ON COLUMN user_general_settings.button_size IS 'גודל כפתורים ביחס לברירת המחדל (0.8-1.4)';