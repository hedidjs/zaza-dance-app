# Supabase Setup Instructions for Zaza Dance App

## Database Schema Setup

1. Create a new Supabase project at https://supabase.com
2. Copy your project URL and anon key
3. Update `lib/core/constants/app_constants.dart` with your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_ACTUAL_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_ACTUAL_SUPABASE_ANON_KEY';
   ```

4. Run the SQL schema from `lib/core/database/supabase_schema_fixed.sql` in your Supabase SQL editor
   ⚠️ **Important**: Use the `supabase_schema_fixed.sql` file (not the original one) to avoid permission errors
5. Run the storage setup from `lib/core/database/storage_buckets.sql` in your Supabase SQL editor

## Enable Real Data

To switch from mock data to real Supabase data:

1. Open `lib/core/providers/data_providers.dart`
2. Change `const bool _useRealData = false;` to `const bool _useRealData = true;`

## Storage Buckets

The following storage buckets will be created:
- profile-images (5MB max)
- gallery-media (50MB max)
- tutorial-videos (100MB max)
- tutorial-thumbnails (2MB max)
- update-images (10MB max)

## Database Tables

- categories: Content categories (Hip Hop, Breakdance, Popping, etc.)
- gallery_items: Images and videos for the gallery
- tutorials: Video tutorials with metadata
- updates: News and announcements
- user_interactions: Likes, views, downloads tracking

## Sample Data

The schema includes sample data to get started. You can modify or add more content through the Supabase dashboard or by inserting more data via SQL.

## Real-time Features

The app is set up to work with Supabase real-time features for:
- Live like counts
- View counts
- New content notifications
- Download progress tracking

## Performance

The app includes advanced caching and offline capabilities:
- Image/video caching with flutter_cache_manager
- Offline tutorial downloads
- Optimized image loading
- Push notifications for new content