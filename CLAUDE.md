# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**זזה דאנס (Zaza Dance)** - A digital home for a hip-hop dance studio community app built with Flutter.

### Vision
Create an exciting, young and inviting digital platform where parents, students and new prospects can feel the rhythm, inspiration and energy of the hip-hop world.

### Core Features
1. **Visual Gallery** - Rich photos and videos showcase
2. **Dance Tutorials** - Video tutorials for students to practice at home  
3. **Hot Updates** - News and updates connecting parents to studio activities
4. **Landing Page** - Impressive landing page for marketing and attracting prospects

## Technology Stack

- **Frontend**: Flutter (iOS + Android)
- **Backend**: Supabase (Database + Auth + Storage)
- **UI/Animation**: flutter_animate, flutter_glow, google_fonts
- **State Management**: Riverpod
- **Navigation**: go_router
- **Language**: Hebrew (RTL support)

## Common Development Commands

### Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d [device_id]

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Project Structure
```
lib/
├── core/
│   ├── constants/     # App constants and colors
│   ├── theme/         # Dark theme with neon colors
│   └── services/      # Supabase and other services
├── features/
│   ├── home/          # Home page
│   ├── gallery/       # Photo/video gallery
│   ├── tutorials/     # Dance tutorials
│   ├── news/          # Updates and announcements
│   └── auth/          # Authentication
└── shared/
    ├── models/        # Data models
    └── widgets/       # Reusable widgets
```

## Design Guidelines

### Theme
- **Dark theme** with neon colors
- **Primary colors**: Fuchsia (#FF00FF) and Turquoise (#40E0D0)
- **RTL support** for Hebrew text
- **Neon glow effects** for text and UI elements

### Typography
- **Font**: Google Fonts Assistant (optimized for Hebrew)
- **Direction**: Right-to-left (RTL)
- **Language**: Hebrew interface

## Database Setup (Supabase)

### Required Environment Variables
```bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Storage Buckets
- `profile-images` - User avatars (5MB limit)
- `gallery-media` - Gallery photos/videos (50MB limit)
- `tutorial-videos` - Tutorial videos (100MB limit)
- `tutorial-thumbnails` - Video thumbnails (2MB limit)
- `update-images` - News article images (10MB limit)

## Testing Strategy

### Device Testing
- **Android**: Test on Samsung Galaxy S10 (SM-G973F) or equivalent
- **iOS**: Test on iPhone devices with iOS 18+
- **RTL Testing**: Verify Hebrew text direction and layout

### Key Testing Areas
1. **RTL Layout**: Ensure proper Hebrew text rendering
2. **Animations**: Verify smooth 60fps animations
3. **Navigation**: Test page transitions and bottom navigation
4. **Theme**: Verify dark theme with neon effects

## Troubleshooting

### Common Issues
1. **Supabase Connection**: Ensure environment variables are set
2. **RTL Issues**: Check Directionality widget wrapper
3. **Animation Performance**: Test on physical devices, not simulators
4. **Hebrew Fonts**: Verify Google Fonts Assistant is loading correctly

### Building Issues
- Run `flutter clean && flutter pub get` if dependencies fail
- For iOS: Run `cd ios && pod install`
- For Android: Ensure Android SDK and licenses are installed