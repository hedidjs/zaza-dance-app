# Zaza Dance Database Troubleshooting Guide

## Issues Identified & Solutions

### 🚨 **CRITICAL ISSUES FOUND:**

#### 1. **Schema Mismatch**
- **Problem:** App expects `gallery_items`, `categories`, `user_interactions` tables but database has different schema
- **Solution:** Run `supabase_database_fix.sql` to align schemas

#### 2. **RLS Policies Blocking Anonymous Users**
- **Problem:** All policies require `auth.uid()` which blocks anonymous access
- **Solution:** New policies allow anonymous read access for public content

#### 3. **Missing Tables**
- **Problem:** `categories` and `user_interactions` tables don't exist
- **Solution:** Created these tables with proper relationships

#### 4. **Authentication Issues**
- **Problem:** Users can't create profiles due to restrictive policies
- **Solution:** Allow profile creation on user registration

---

## 🔧 **STEP-BY-STEP FIX PROCESS:**

### Step 1: Run Database Fix Script
```sql
-- Execute in Supabase SQL Editor:
-- Copy and paste contents of supabase_database_fix.sql
```

### Step 2: Verify Storage Buckets
In Supabase Dashboard → Storage, ensure these buckets exist:

| Bucket Name | Public | File Size Limit | MIME Types |
|-------------|--------|------------------|------------|
| `profile-images` | ✅ Yes | 5MB | `image/*` |
| `gallery-media` | ✅ Yes | 50MB | `image/*, video/*` |
| `tutorial-videos` | ✅ Yes | 100MB | `video/*` |
| `tutorial-thumbnails` | ✅ Yes | 2MB | `image/*` |
| `update-images` | ✅ Yes | 10MB | `image/*` |

### Step 3: Test Database Connectivity
```bash
# Test from terminal with curl:
curl -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5dm9hdnpnYXBzeXljandpcm1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyOTgyMzgsImV4cCI6MjA3MDg3NDIzOH0.IU_dW_8K-yuV1grWIWJdetU7jK-b-QDPFYp_m5iFP90" \
  "https://yyvoavzgapsyycjwirmg.supabase.co/rest/v1/categories?select=*"
```

### Step 4: Test App Operations
1. **Gallery Loading:** Should load sample images
2. **Profile Updates:** Should save without authentication issues
3. **Updates/News:** Should display sample content
4. **User Interactions:** Should track likes/views anonymously

---

## 🧪 **TESTING CHECKLIST:**

### ✅ Database Operations
- [ ] Categories load successfully
- [ ] Gallery items display
- [ ] Tutorials show up
- [ ] Updates/news are visible
- [ ] User interactions work (likes, views)

### ✅ Authentication Flow  
- [ ] Anonymous users can browse content
- [ ] User registration creates profile
- [ ] Profile updates save correctly
- [ ] Admin users can manage content

### ✅ Storage Operations
- [ ] Images display correctly
- [ ] File uploads work for authenticated users
- [ ] Public content is accessible without auth

---

## 🔍 **DEBUGGING COMMANDS:**

### Check Table Structure
```sql
-- Verify tables exist with correct columns:
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'categories', 'gallery_items', 'tutorials', 'updates', 'user_interactions')
ORDER BY table_name, ordinal_position;
```

### Check RLS Policies
```sql
-- Verify RLS policies allow anonymous access:
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

### Check Sample Data
```sql
-- Verify sample data exists:
SELECT 'categories' as table_name, count(*) as row_count FROM public.categories
UNION ALL
SELECT 'gallery_items', count(*) FROM public.gallery_items  
UNION ALL
SELECT 'tutorials', count(*) FROM public.tutorials
UNION ALL
SELECT 'updates', count(*) FROM public.updates;
```

### Test Anonymous Access
```sql
-- Test if anonymous users can read data:
SET ROLE anon;
SELECT * FROM public.categories LIMIT 1;
SELECT * FROM public.gallery_items LIMIT 1;
SELECT * FROM public.tutorials LIMIT 1;
SELECT * FROM public.updates LIMIT 1;
RESET ROLE;
```

---

## 🚫 **COMMON ERROR MESSAGES & FIXES:**

### Error: "relation 'categories' does not exist"
**Fix:** Run the database fix script to create missing tables

### Error: "new row violates row-level security policy"  
**Fix:** Check RLS policies allow the operation for anonymous users

### Error: "permission denied for table"
**Fix:** Ensure RLS is enabled and policies are correctly configured

### Error: "column 'category_id' does not exist"
**Fix:** Run schema alignment part of the fix script

---

## ⚡ **PERFORMANCE OPTIMIZATIONS:**

### Database Indexes
```sql
-- Key indexes for performance:
CREATE INDEX IF NOT EXISTS idx_gallery_items_featured_active ON gallery_items(is_featured, is_active);
CREATE INDEX IF NOT EXISTS idx_tutorials_difficulty_active ON tutorials(difficulty_level, is_active);  
CREATE INDEX IF NOT EXISTS idx_updates_pinned_date ON updates(is_pinned, publish_date DESC);
CREATE INDEX IF NOT EXISTS idx_user_interactions_device_content ON user_interactions(user_device_id, content_type, content_id);
```

### Connection Pool Settings
```dart
// In Supabase initialization:
await Supabase.initialize(
  url: Environment.supabaseUrl,
  anonKey: Environment.supabaseAnonKey,
  debug: Environment.enableDebugLogs,
  // Add connection settings:
  localStorage: const SharedPreferencesLocalStorage(),
  detectSessionInUri: false,
  authFlowType: AuthFlowType.pkce,
);
```

---

## 📊 **MONITORING & MAINTENANCE:**

### Daily Checks
- Monitor error logs in Supabase Dashboard
- Check storage usage and cleanup old files
- Review anonymous user interaction patterns

### Weekly Maintenance  
- Clean up old user interaction records
- Optimize database queries
- Update content metadata

### Monthly Tasks
- Review and update RLS policies
- Check for unused storage files
- Performance optimization review

---

## 🆘 **EMERGENCY ROLLBACK:**

If something goes wrong, restore from backup:

```sql
-- Emergency: Disable RLS temporarily
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_items DISABLE ROW LEVEL SECURITY;  
ALTER TABLE public.tutorials DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.updates DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions DISABLE ROW LEVEL SECURITY;

-- Re-enable after fixing issues
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorials ENABLE ROW LEVEL SECURITY;  
ALTER TABLE public.updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
```

---

## 📞 **SUPPORT CONTACTS:**

- **Database Issues:** Check Supabase Dashboard logs
- **App Errors:** Enable debug mode in Flutter  
- **Storage Problems:** Verify bucket permissions
- **RLS Issues:** Test with SQL commands above

**Remember:** Always test changes in development before applying to production!