# עמוד עריכת פרופיל מתקדם - זזה דאנס

## תיאור כללי

עמוד עריכת פרופיל מתקדם המיועד לאפליקציית זזה דאנס, עם עיצוב עקבי לאסתטיקה של היפ הופ ותמיכה מלאה בעברית RTL.

## תכונות עיקריות

### 🎨 עיצוב ואנימציות
- **זוהר עדין** - אפקטי נאון עדינים שמתאימים לאסתטיקה של היפ הופ
- **Hebrew RTL** - תמיכה מלאה בכיוון כתיבה מימין לשמאל
- **אנימציות חלקות** - מעברים ואפקטים ויזואליים מלוטשים
- **עיצוב עקבי** - בהתאם לשפת העיצוב של האפליקציה

### 📝 שדות עריכה
- **תמונת פרופיל** - עם preview ואפשרות מחיקה
- **שם מלא** - שדה נדרש עם validation מתקדם
- **אימייל** - קריאה בלבד (לא ניתן לשינוי)
- **טלפון** - עם validation למספרי טלפון ישראליים
- **כתובת** - שדה מרובה שורות
- **תאריך לידה** - עם date picker מותאם לעברית
- **ביוגרפיה** - עד 500 תווים

### 🔧 תכונות מתקדמות
- **Auto-save** - שמירה אוטומטית כל 10 שניות
- **Loading states** - מצבי טעינה חזותיים ומידע על התקדמות
- **Success feedback** - הודעות הצלחה אינטראקטיביות
- **Error handling** - טיפול בשגיאות עם הודעות ברורות
- **Image compression** - דחיסת תמונות אוטומטית לפני העלאה
- **Unsaved changes warning** - אזהרה בעת יציאה עם שינויים לא שמורים

### 🚀 ביצועים ואבטחה
- **Validation חכם** - בדיקות שדות מתקדמות בזמן אמת
- **דחיסת תמונות** - אופטימיזציה אוטומטית של גודל ואיכות
- **Memory management** - ניהול זיכרון יעיל
- **Network optimization** - העלאות אופטימליות לשרת

## מבנה הקבצים

```
lib/features/profile/presentation/
├── pages/
│   ├── edit_profile_page.dart           # העמוד הראשי
│   └── profile_page.dart                # עמוד הפרופיל המעודכן
├── providers/
│   └── edit_profile_provider.dart       # ניהול state מתקדם
└── widgets/
    ├── profile_image_picker.dart        # רכיב בחירת תמונה
    ├── profile_form_field.dart          # שדות טופס מתקדמים
    ├── auto_save_indicator.dart         # אינדיקטור שמירה אוטומטית
    └── image_compression_handler.dart   # טיפול בדחיסת תמונות
```

## רכיבים עיקריים

### EditProfilePage
העמוד הראשי לעריכת פרופיל, כולל:
- ניהול state מתקדם
- Auto-save functionality  
- Validation בזמן אמת
- ניהול תמונות
- Unsaved changes warning

### EditProfileProvider
Provider לניהול מצב העריכה:
- Auto-save מתוזמן
- Loading states
- Error handling
- Image upload management

### ProfileImagePicker
רכיב מתקדם לבחירת והעלאת תמונות:
- בחירה מגלריה או מצלמה
- דחיסה אוטומטית
- Preview והסרת תמונות
- Loading states

### ProfileFormField
שדות טופס מותאמים אישית:
- Validation מתקדם
- אנימציות על focus
- תמיכה בעברית RTL
- Error messaging

### AutoSaveIndicator
אינדיקטור ויזואלי לשמירה אוטומטית:
- סטטוס שמירה בזמן אמת
- אנימציות מתקדמות
- הודעות למשתמש

## שימוש

### ניווט לעמוד
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const EditProfilePage(),
  ),
);
```

### שימוש ב-Provider
```dart
// צפייה במצב העריכה
final editState = ref.watch(editProfileProvider);

// עדכון פרופיל
await ref.read(editProfileProvider.notifier).saveProfile(
  userId: userId,
  fullName: fullName,
  phoneNumber: phoneNumber,
  // ...
);
```

## דרישות מערכת

### Dependencies
```yaml
dependencies:
  flutter_image_compress: ^2.3.0
  image_picker: ^1.1.2
  path_provider: ^2.1.4
  intl: ^0.20.2
```

### הרשאות
```xml
<!-- Android -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- iOS -->
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take profile pictures.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select profile pictures.</string>
```

## תכונות נוספות מתוכננות

- [ ] גיבוי מקומי של שינויים
- [ ] סנכרון עם מספר מכשירים
- [ ] עריכת פרופיל במצב offline
- [ ] ייבוא נתונים ממקורות חיצוניים
- [ ] תמיכה בפורמטים נוספים של תמונות

## נושאי פיתוח

### Performance
- שימוש ב-lazy loading לתמונות
- דחיסה מתקדמת של תמונות
- Cache management חכם

### UX/UI
- הנגשה מלאה
- תמיכה במצבי תצוגה שונים
- אנימציות רספונסיביות

### אבטחה
- Validation צד לקוח וצד שרת
- הצפנת נתונים רגישים
- Rate limiting על העלאות

---

נוצר עבור **זזה דאנס** - בית דיגיטלי לקהילת חוג ההיפ הופ