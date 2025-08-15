-- Sample data for Zaza Dance App (for testing purposes)
-- This migration can be run optionally for development/testing

-- Insert sample users (passwords will be handled by Supabase Auth)
INSERT INTO users (id, email, full_name, phone, role, bio) VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'admin@zazadance.com',
    'זאזא מנהלת',
    '050-1234567',
    'admin',
    'מנהלת סטודיו הריקוד זאזא'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'instructor@zazadance.com',
    'מיכל מורה',
    '050-2345678',
    'instructor',
    'מורה לריקוד עם 10 שנות ניסיון'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'parent@example.com',
    'דוד הורה',
    '050-3456789',
    'parent',
    'הורה לתלמידה בסטודיו'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'student@example.com',
    'שרה תלמידה',
    '050-4567890',
    'student',
    'תלמידה נלהבת לריקוד'
  );

-- Insert sample gallery items
INSERT INTO gallery (title, description, media_type, media_url, is_featured, uploaded_by) VALUES
  (
    'תצוגת סוף שנה 2024',
    'רגעים מיוחדים מתצוגת סוף השנה של תלמידות הסטודיו',
    'photo',
    'https://example.com/gallery/showcase-2024.jpg',
    true,
    '22222222-2222-2222-2222-222222222222'
  ),
  (
    'שיעור ריקוד יצירתי',
    'קטע מתוך שיעור ריקוד יצירתי לילדות',
    'video',
    'https://example.com/gallery/creative-dance.mp4',
    true,
    '22222222-2222-2222-2222-222222222222'
  ),
  (
    'תלמידות בפעילות',
    'תמונות מהשיעורים השבועיים',
    'photo',
    'https://example.com/gallery/students-activity.jpg',
    false,
    '11111111-1111-1111-1111-111111111111'
  );

-- Insert sample tutorials
INSERT INTO tutorials (title, description, video_url, difficulty_level, duration_minutes, dance_style, is_published, instructor_id) VALUES
  (
    'יסודות הריקוד - שיעור 1',
    'למידת התנועות הבסיסיות בריקוד. מתאים למתחילות',
    'https://example.com/tutorials/basics-lesson-1.mp4',
    'beginner',
    15,
    'ריקוד יצירתי',
    true,
    '22222222-2222-2222-2222-222222222222'
  ),
  (
    'כוריאוגרפיה מתקדמת',
    'רצף תנועות מתקדם לתלמידות מנוסות',
    'https://example.com/tutorials/advanced-choreo.mp4',
    'advanced',
    25,
    'ריקוד מודרני',
    true,
    '22222222-2222-2222-2222-222222222222'
  ),
  (
    'חימום לפני השיעור',
    'תרגילי חימום חשובים לכל שיעור ריקוד',
    'https://example.com/tutorials/warmup.mp4',
    'beginner',
    10,
    'כללי',
    true,
    '22222222-2222-2222-2222-222222222222'
  );

-- Insert sample updates/news
INSERT INTO updates (title, content, excerpt, is_published, is_pinned, author_id, published_at) VALUES
  (
    'פתיחת הרישום לשנת הלימודים החדשה',
    'שלום רב! אנו שמחות לבשר על פתיחת הרישום לשנת הלימודים החדשה 2024-2025. השנה נציע קבוצות חדשות לגילאים שונים ורמות שונות. פרטים נוספים באתר או בטלפון 050-1234567.',
    'פתיחת הרישום לשנת הלימודים החדשה 2024-2025',
    true,
    true,
    '11111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '2 days'
  ),
  (
    'תצוגת סוף שנה מיוחדת',
    'התלמידות שלנו מתכוננות לתצוגת סוף שנה מרגשת. התצוגה תתקיים בחודש יוני במרכז התרבות העירוני. כל המשפחות מוזמנות לבוא ולהתרגש יחד איתנו!',
    'התצוגה תתקיים בחודש יוני במרכז התרבות העירוני',
    true,
    false,
    '11111111-1111-1111-1111-111111111111',
    NOW() - INTERVAL '1 week'
  ),
  (
    'סדנת מוריות אורחות',
    'השבוע נארח מוריות אורחות מהארץ ומחו"ל לסדנאות מיוחדות. זו הזדמנות נהדרת לתלמידות שלנו ללמוד סגנונות ריקוד חדשים ומעניינים.',
    'סדנאות מיוחדות עם מוריות אורחות',
    true,
    false,
    '22222222-2222-2222-2222-222222222222',
    NOW() - INTERVAL '3 days'
  );