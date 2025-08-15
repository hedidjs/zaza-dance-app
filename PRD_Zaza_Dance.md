# Product Requirements Document
## Zaza Dance Hip-Hop Studio App

### Vision Statement
Create an exciting, young and inviting digital home for the dance studio community - where parents, students and new prospects can feel the rhythm, inspiration and energy of the hip-hop world.

---

## Core Features

### 1. Visual Gallery
**Purpose**: Rich showcase of studio energy and community
- **Photo Gallery**: High-quality images of classes, performances, students, and studio environment
- **Video Gallery**: Performance videos, behind-the-scenes content, studio highlights
- **Organization**: Simple categorization (Classes, Performances, Studio Life, Students)
- **Hebrew Support**: RTL text overlay support for image/video descriptions

### 2. Dance Tutorials
**Purpose**: Enable students to practice at home and stay connected
- **Video Tutorials**: Step-by-step dance instruction videos
- **Skill Levels**: Beginner, Intermediate, Advanced categorization
- **Search & Filter**: Easy discovery by dance style, difficulty, instructor
- **Offline Viewing**: Download capability for practice without internet
- **Hebrew Interface**: RTL navigation and Hebrew video titles/descriptions

### 3. Hot Updates
**Purpose**: Keep parents and students connected to studio happenings
- **News Feed**: Latest studio news, achievements, upcoming events
- **Student Spotlights**: Celebrating student achievements and milestones
- **Instructor Updates**: Messages and tips from dance instructors
- **Push Notifications**: Important announcements and reminders
- **Hebrew Content**: Full RTL support for all text content

### 4. Landing Page
**Purpose**: Impressive entry point for marketing and attracting prospects
- **Hero Section**: Eye-catching video/image carousel showcasing studio energy
- **About Studio**: Brief, inspiring description of Zaza Dance philosophy
- **Quick Gallery Preview**: Teaser of photos/videos to entice exploration
- **Contact Information**: Easy access to studio location, phone, social media
- **Call-to-Action**: Clear invitation to visit studio or learn more

---

## Design Requirements

### Visual Style
- **Theme**: Dark background with glowing text effects
- **Color Palette**:
  - Primary: Fuchsia neon (#FF00FF, #E91E63)
  - Secondary: Turquoise neon (#00FFFF, #26C6DA)
  - Background: Dark gradients (#0A0A0A, #1A1A1A, #2A2A2A)
  - Text: White and neon glows

### Atmosphere & Branding
- **Vibe**: Young, vibrant, energetic hip-hop culture
- **Typography**: Bold, modern fonts with glow effects
- **Visual Elements**: Neon light inspirations, dance floor aesthetics
- **Animations**: Smooth, rhythmic transitions that feel musical

### Hebrew RTL Support
- **Layout**: Full right-to-left layout adaptation
- **Navigation**: RTL-appropriate menu structures
- **Text Flow**: Proper Hebrew text rendering and alignment
- **Mixed Content**: Support for Hebrew text with English dance terms

---

## Technical Requirements

### Platform & Framework
- **Technology**: Flutter (Dart)
- **Deployment**: iOS App Store + Google Play Store
- **Minimum Versions**: iOS 12+, Android 8+

### Backend & Storage
- **Database**: Supabase PostgreSQL
- **Media Storage**: Supabase Storage for images and videos
- **Authentication**: Simple access (no complex user management needed)
- **Real-time**: Supabase real-time for live updates

### Performance & Media
- **Video Streaming**: Optimized playback with quality selection
- **Image Optimization**: Multiple resolutions for different devices
- **Caching**: Local caching for improved performance
- **Offline Support**: Download tutorials for offline viewing

### Localization
- **Primary Language**: Hebrew (RTL)
- **Font Support**: Hebrew typography with neon styling capability
- **Date/Time**: Hebrew calendar and time format support

---

## User Experience Flow

### New User Journey
1. **Landing Page**: Immediate visual impact with studio energy
2. **Gallery Browse**: Explore photos/videos to feel the vibe
3. **Tutorial Discovery**: Find practice content
4. **Updates Check**: Stay connected with studio news

### Returning User Journey
1. **Quick Updates**: Check latest news and announcements
2. **Tutorial Practice**: Access downloaded or new practice videos
3. **Gallery Updates**: View new photos and performance videos
4. **Community Connection**: Feel part of the studio family

---

## Success Metrics

### Engagement Metrics
- Time spent in Visual Gallery
- Tutorial video completion rates
- Frequency of app opens for Updates
- Social sharing of gallery content

### Community Building
- Parent engagement with studio updates
- Student tutorial usage frequency
- New prospect conversion from Landing Page

---

## Development Phases

### Phase 1: Core Foundation
- Landing Page with basic gallery preview
- Visual Gallery with photo/video display
- Basic Hebrew RTL support

### Phase 2: Interactive Features
- Dance Tutorials with video playback
- Hot Updates news feed
- Enhanced neon styling and animations

### Phase 3: Polish & Optimization
- Advanced Hebrew typography
- Performance optimizations
- Push notifications
- Offline tutorial downloads

---

## Constraints & Limitations

### Scope Boundaries
- **NO payment systems**
- **NO class booking functionality**
- **NO complex user management**
- **NO social features beyond gallery viewing**
- **NO live streaming capabilities**

### Technical Constraints
- Simple, maintainable codebase
- Quick loading times essential
- Reliable media playback required
- Smooth Hebrew RTL experience mandatory

---

## Definition of Done

The Zaza Dance app successfully creates a digital home that:
- Showcases the energy and community of the hip-hop studio
- Provides valuable practice content for students
- Keeps parents connected and informed
- Attracts new prospects with compelling visual presentation
- Delivers a smooth, exciting user experience in Hebrew RTL
- Maintains the young, vibrant hip-hop aesthetic throughout