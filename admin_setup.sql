-- הגדרת מנהל מערכת לאפליקציית זזה דאנס
-- יש להריץ את הסקריפט הזה ב-SQL Editor של Supabase

-- 1. עדכון המשתמש hedidjs@gmail.com למנהל מערכת
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

-- 2. עדכון בטבלת הפרופילים (אם הטבלה קיימת)
UPDATE user_profiles 
SET 
  role = 'admin',
  updated_at = NOW()
WHERE email = 'hedidjs@gmail.com';

-- 3. יצירת רשומה אם המשתמש לא קיים בטבלת הפרופילים
INSERT INTO user_profiles (
  id, 
  email, 
  full_name, 
  role, 
  created_at, 
  updated_at
)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'full_name', 'מנהל מערכת'),
  'admin',
  NOW(),
  NOW()
FROM auth.users 
WHERE email = 'hedidjs@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM user_profiles WHERE email = 'hedidjs@gmail.com'
  );

-- 4. בדיקה שההגדרה הצליחה
SELECT 
  id,
  email,
  raw_app_meta_data->>'role' as app_role,
  raw_user_meta_data->>'role' as user_role,
  created_at
FROM auth.users 
WHERE email = 'hedidjs@gmail.com';

-- הודעת אישור
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM auth.users 
    WHERE email = 'hedidjs@gmail.com' 
    AND raw_app_meta_data->>'role' = 'admin'
  ) THEN
    RAISE NOTICE 'המשתמש hedidjs@gmail.com הוגדר בהצלחה כמנהל מערכת!';
  ELSE
    RAISE NOTICE 'שגיאה: המשתמש hedidjs@gmail.com לא נמצא או לא הוגדר כמנהל';
  END IF;
END $$;