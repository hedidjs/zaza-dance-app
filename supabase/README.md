# Zaza Dance App - Supabase Database Schema

A simple database schema for the Zaza Dance studio app focusing on core features: Users, Gallery, Tutorials, and Updates/News.

## Features

### 1. Users Management
- Simple user registration and profiles
- Role-based access (student, parent, instructor, admin)
- Hebrew text support for names and bios

### 2. Gallery
- Photo and video showcase
- Featured content highlighting
- Media organization with titles and descriptions

### 3. Tutorials
- Dance tutorial videos
- Difficulty levels (beginner, intermediate, advanced)
- Instructor management and publishing controls

### 4. Updates/News
- Studio announcements and news
- Pinned important updates
- Rich content with images

## Database Structure

### Tables
- `users` - User profiles and authentication
- `gallery` - Photo and video showcase
- `tutorials` - Dance tutorial videos
- `updates` - Studio news and announcements

### Storage Buckets
- `profile-images` - User profile pictures (5MB limit)
- `gallery-media` - Gallery photos and videos (50MB limit)
- `tutorial-videos` - Tutorial videos (100MB limit)
- `tutorial-thumbnails` - Video thumbnails (2MB limit)
- `update-images` - News article images (10MB limit)

### Security Features
- Row Level Security (RLS) enabled on all tables
- Role-based access control
- Secure storage policies
- Automatic timestamp management

## Setup Instructions

### Prerequisites
- Supabase CLI installed
- Node.js (for local development)

### Local Development Setup

1. **Initialize Supabase project:**
   ```bash
   supabase init
   ```

2. **Start local Supabase:**
   ```bash
   supabase start
   ```

3. **Run migrations:**
   ```bash
   supabase db reset
   ```

4. **Access local services:**
   - Studio: http://localhost:54330
   - API: http://localhost:54321
   - Auth: http://localhost:54322

### Production Deployment

1. **Link to your Supabase project:**
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

2. **Deploy migrations:**
   ```bash
   supabase db push
   ```

## Migration Files

1. `20250815000001_initial_schema.sql` - Core tables and indexes
2. `20250815000002_rls_policies.sql` - Security policies
3. `20250815000003_storage_setup.sql` - Storage buckets and policies
4. `20250815000004_sample_data.sql` - Sample data (optional, for testing)

## Usage Examples

### Create a new user (via Supabase Auth)
Users are created through Supabase Auth, then their profile is completed in the users table.

### Add gallery content
Instructors and admins can upload photos/videos to the gallery with Hebrew descriptions.

### Publish tutorials
Instructors can create and publish tutorial videos with difficulty levels and descriptions.

### Post updates
Administrators can post studio updates and news, with the ability to pin important announcements.

## Security Notes

- All tables have RLS enabled
- Users can only edit their own profiles
- Content creation restricted to instructors and admins
- Public read access for published content
- Secure file upload policies based on user roles

## Hebrew Text Support

The database is configured to handle Hebrew text properly:
- UTF-8 encoding
- Proper collation for Hebrew sorting
- Text fields sized appropriately for Hebrew content

## File Size Limits

- Profile images: 5MB
- Gallery media: 50MB
- Tutorial videos: 100MB
- Thumbnails: 2MB
- Update images: 10MB