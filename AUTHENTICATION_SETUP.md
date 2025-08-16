# Authentication System Setup Guide

## Overview
The Zaza Dance app now includes a complete authentication system with:
- User registration with full details (name, email, phone, address)
- Login/logout functionality  
- Role-based access control (student, parent, instructor, admin)
- Profile management
- Supabase integration

## Database Setup

### 1. Supabase Project Setup
1. Go to [Supabase](https://supabase.com) and create a new project
2. Once your project is ready, go to the SQL Editor
3. Run the SQL schema from `database_schema.sql` to set up:
   - User profiles table
   - Storage buckets for images/videos
   - Row Level Security policies
   - Automatic triggers for user creation

### 2. Environment Configuration
Make sure your `lib/core/constants/app_constants.dart` has the correct Supabase URL and anon key:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## Features Implemented

### ✅ Authentication System (Phase 4.1)
- **Supabase Integration**: Full setup with auth service and providers
- **Registration Form**: Complete form with name, email, phone, address
- **Login/Logout**: Secure authentication flow
- **User Model**: Comprehensive user data structure
- **Auth Provider**: Riverpod state management for authentication

### ✅ User Types & Roles (Phase 4.2)
- **Student**: Default role for new registrations
- **Parent**: For parents managing children's accounts
- **Instructor**: Dance instructors with content access
- **Admin**: Full system administration rights

### ✅ Role-Based Access Control (Phase 4.3)
- **Provider-based checking**: `isAdminProvider`, `isInstructorProvider`, etc.
- **Database policies**: RLS policies enforce access control
- **UI conditional rendering**: Different interfaces based on user role

## User Flow

### Registration Process
1. User accesses the landing page
2. Clicks "גלה את הקסם" to open login page
3. Navigates to registration page
4. Fills out complete form:
   - Full name (required)
   - Email (required)
   - Phone number (required)
   - Address (optional)
   - User type (student/parent)
   - Password (required, min 6 chars)
   - Confirm password (required)
5. Account created and profile stored in database

### Login Process
1. User enters email and password
2. System authenticates with Supabase
3. User profile loaded from database
4. Redirected to home page based on role

### Authentication Flow
- **Landing Page**: Shows for unauthenticated users
- **Loading Page**: Shows during authentication state checks
- **Home Page**: Shows for authenticated users
- **Login Page**: Shows on authentication errors

## File Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Supabase config & user roles
│   │   └── app_colors.dart         # UI colors including auth themes
│   ├── models/
│   │   └── user_model.dart         # Complete user data model
│   ├── providers/
│   │   └── auth_provider.dart      # Authentication state management
│   └── services/
│       └── auth_service.dart       # Supabase auth operations
├── features/
│   └── auth/
│       └── presentation/
│           └── pages/
│               ├── login_page.dart     # Login UI
│               └── register_page.dart  # Registration UI
└── main.dart                       # App initialization with Supabase
```

## Security Features

### Database Security
- **Row Level Security (RLS)**: Enabled on all tables
- **User Isolation**: Users can only access their own data
- **Role-based Access**: Admins/instructors have elevated permissions
- **Storage Policies**: Secure file upload/access policies

### App Security
- **Password Validation**: Minimum length requirements
- **Email Validation**: Proper email format checking
- **Input Sanitization**: All user inputs validated
- **Error Handling**: Comprehensive error messages

## Next Steps

### Pending Features (Phase 5+)
- **Profile Management**: Edit profile functionality
- **Settings Pages**: User preferences and notifications
- **Admin Dashboard**: Content and user management
- **Password Reset**: Email-based password recovery
- **Email Verification**: Verify user email addresses

### Database Extensions
- Add more user metadata fields as needed
- Implement soft delete for user accounts
- Add user activity logging
- Create backup and recovery procedures

## Testing

### Manual Testing
1. Test registration with various input combinations
2. Test login/logout flow
3. Test role-based access control
4. Test form validation and error handling
5. Test password reset functionality

### Automated Testing
- Unit tests for auth service methods
- Widget tests for login/register forms
- Integration tests for complete auth flow

## Troubleshooting

### Common Issues
1. **Supabase connection**: Check URL and anon key
2. **Database policies**: Ensure RLS policies are correct
3. **Storage access**: Verify bucket policies and permissions
4. **Form validation**: Check required field validation
5. **Navigation**: Ensure route setup is correct

### Debug Mode
The app includes debug logging for authentication operations. Check console output for detailed information during development.

## Production Considerations

### Security
- Use environment variables for sensitive config
- Enable email verification for production
- Implement rate limiting for auth endpoints
- Use HTTPS for all communications

### Performance
- Implement proper loading states
- Cache user data appropriately
- Optimize database queries
- Use connection pooling for high traffic

### Monitoring
- Track authentication success/failure rates
- Monitor user registration trends
- Log security events and failed attempts
- Set up alerts for unusual activity