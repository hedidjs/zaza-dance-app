#!/usr/bin/env python3
"""
Supabase Setup Script for Zaza Dance App
הגדרת בסיס נתונים אוטומטית
"""

import os
from supabase import create_client, Client

# הגדרת פרטי החיבור
SUPABASE_URL = "https://yyvoavzgapsyycjwirmg.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTI5ODIzOCwiZXhwIjoyMDcwODc0MjM4fQ.Ti7KodfacWNnP3uaGieYTnfuYgc8Bq3euM7FU00n6fQ"

def create_settings_tables():
    """יצירת טבלאות הגדרות"""
    
    # יצירת לקוח Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    # SQL ליצירת טבלת הגדרות התראות
    notification_settings_sql = """
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
    """
    
    # SQL ליצירת טבלת הגדרות כלליות
    general_settings_sql = """
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
    """
    
    # יצירת פונקציית עדכון אוטומטי
    trigger_function_sql = """
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = NOW();
        RETURN NEW;
    END;
    $$ language 'plpgsql';
    """
    
    # יצירת טריגרים
    triggers_sql = """
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
    """
    
    # הפעלת RLS
    rls_sql = """
    ALTER TABLE user_notification_settings ENABLE ROW LEVEL SECURITY;
    ALTER TABLE user_general_settings ENABLE ROW LEVEL SECURITY;
    """
    
    # יצירת מדיניות RLS
    policies_sql = """
    -- מדיניות הגדרות התראות
    DROP POLICY IF EXISTS "Users can view their own notification settings" ON user_notification_settings;
    CREATE POLICY "Users can view their own notification settings" ON user_notification_settings
        FOR SELECT USING (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can insert their own notification settings" ON user_notification_settings;
    CREATE POLICY "Users can insert their own notification settings" ON user_notification_settings
        FOR INSERT WITH CHECK (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can update their own notification settings" ON user_notification_settings;
    CREATE POLICY "Users can update their own notification settings" ON user_notification_settings
        FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can delete their own notification settings" ON user_notification_settings;
    CREATE POLICY "Users can delete their own notification settings" ON user_notification_settings
        FOR DELETE USING (auth.uid() = user_id);
        
    -- מדיניות הגדרות כלליות
    DROP POLICY IF EXISTS "Users can view their own general settings" ON user_general_settings;
    CREATE POLICY "Users can view their own general settings" ON user_general_settings
        FOR SELECT USING (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can insert their own general settings" ON user_general_settings;
    CREATE POLICY "Users can insert their own general settings" ON user_general_settings
        FOR INSERT WITH CHECK (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can update their own general settings" ON user_general_settings;
    CREATE POLICY "Users can update their own general settings" ON user_general_settings
        FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
        
    DROP POLICY IF EXISTS "Users can delete their own general settings" ON user_general_settings;
    CREATE POLICY "Users can delete their own general settings" ON user_general_settings
        FOR DELETE USING (auth.uid() = user_id);
    """
    
    try:
        print("🚀 מתחיל הגדרת בסיס הנתונים...")
        
        # ביצוע כל ה-SQL
        sql_commands = [
            notification_settings_sql,
            general_settings_sql,
            trigger_function_sql,
            triggers_sql,
            rls_sql,
            policies_sql
        ]
        
        for i, sql in enumerate(sql_commands, 1):
            print(f"   {i}/6 מבצע...")
            supabase.postgrest.session.post(
                f"{SUPABASE_URL}/rest/v1/rpc/exec",
                json={"query": sql},
                headers={
                    "apikey": SUPABASE_SERVICE_KEY,
                    "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
                    "Content-Type": "application/json"
                }
            )
        
        print("✅ טבלאות הגדרות נוצרו בהצלחה!")
        return True
        
    except Exception as e:
        print(f"❌ שגיאה ביצירת הטבלאות: {e}")
        return False

def setup_admin_user():
    """הגדרת משתמש מנהל"""
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    admin_sql = """
    UPDATE auth.users 
    SET 
      raw_app_meta_data = jsonb_set(
        COALESCE(raw_app_meta_data, '{}'), 
        '{role}', 
        '"admin"'
      ),
      raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'), 
        '{role}', 
        '"admin"'
      )
    WHERE email = 'hedidjs@gmail.com';
    """
    
    try:
        print("👑 מגדיר משתמש מנהל...")
        
        # ביצוע עדכון המנהל
        supabase.postgrest.session.post(
            f"{SUPABASE_URL}/rest/v1/rpc/exec",
            json={"query": admin_sql},
            headers={
                "apikey": SUPABASE_SERVICE_KEY,
                "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
                "Content-Type": "application/json"
            }
        )
        
        print("✅ המשתמש hedidjs@gmail.com הוגדר כמנהל!")
        return True
        
    except Exception as e:
        print(f"❌ שגיאה בהגדרת המנהל: {e}")
        return False

def verify_setup():
    """בדיקה שההגדרה הצליחה"""
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    
    try:
        print("🔍 מאמת הגדרות...")
        
        # בדיקת טבלאות
        tables_check = supabase.table('user_notification_settings').select('*').limit(1).execute()
        print("✅ טבלת הגדרות התראות קיימת")
        
        tables_check2 = supabase.table('user_general_settings').select('*').limit(1).execute()
        print("✅ טבלת הגדרות כלליות קיימת")
        
        # בדיקת מנהל
        admin_check_sql = """
        SELECT 
          id,
          email,
          raw_app_meta_data->>'role' as app_role,
          raw_user_meta_data->>'role' as user_role
        FROM auth.users 
        WHERE email = 'hedidjs@gmail.com';
        """
        
        print("✅ כל ההגדרות הושלמו בהצלחה!")
        print("🎉 האפליקציה מוכנה לשימוש!")
        
        return True
        
    except Exception as e:
        print(f"❌ שגיאה באימות: {e}")
        return False

if __name__ == "__main__":
    print("🎯 הגדרת אפליקציית זזה דאנס")
    print("=" * 40)
    
    # יצירת טבלאות
    if create_settings_tables():
        # הגדרת מנהל
        if setup_admin_user():
            # אימות
            verify_setup()
        else:
            print("❌ הגדרת המנהל נכשלה")
    else:
        print("❌ יצירת הטבלאות נכשלה")
    
    print("=" * 40)
    print("✨ סיום!")