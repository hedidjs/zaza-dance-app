-- Supabase Auth Configuration for zazadance.com Domain
-- This script configures the redirect URLs for email confirmation and Deep Links

-- Note: These settings need to be configured in Supabase Dashboard
-- Go to Authentication > URL Configuration

-- Site URL (Main domain): https://zazadance.com
-- Additional redirect URLs:
-- https://zazadance.com/auth/callback
-- https://zazadance.com/#/auth/callback
-- https://zazadance.com/welcome
-- com.zazadance.zazaDance://auth/callback (for mobile deep links)
-- com.zazadance.zazaDance://welcome (for mobile deep links)
-- com.zazadance.zazaDance:// (for mobile app opening)

-- Email Templates Configuration:
-- Confirmation Email: https://zazadance.com/auth/callback?token={{ .Token }}&type=email_confirmation
-- Reset Password: https://zazadance.com/auth/callback?token={{ .Token }}&type=password_reset
-- Magic Link: https://zazadance.com/auth/callback?token={{ .Token }}&type=magic_link

-- Mobile Deep Link Configuration:
-- The web app will detect mobile devices and try to redirect to:
-- com.zazadance.zazaDance://auth/callback?code={{ .Token }}

-- Custom SMTP Settings (if needed):
-- SMTP Host: Your email provider's SMTP host
-- SMTP Port: 587 (TLS) or 465 (SSL)
-- SMTP User: Your email address
-- SMTP Pass: Your email password or app password

-- Instructions for Supabase Dashboard Configuration:
-- 1. Go to Supabase Dashboard > Authentication > URL Configuration
-- 2. Set Site URL to: https://zazadance.com
-- 3. Add ALL redirect URLs listed above (one per line):
--    https://zazadance.com/auth/callback
--    https://zazadance.com/#/auth/callback
--    https://zazadance.com/welcome
--    com.zazadance.zazaDance://auth/callback
--    com.zazadance.zazaDance://welcome
--    com.zazadance.zazaDance://
-- 4. Go to Authentication > Email Templates
-- 5. Update email templates with URLs from above
-- 6. Test the complete authentication flow:
--    a. Web user registration
--    b. Email confirmation from mobile device
--    c. Deep link redirect back to app

-- For development, you can also add:
-- http://localhost:8080 (for local web development)
-- http://localhost:3000 (for alternative web development)
-- Additional URLs as needed

-- Mobile App Link Verification:
-- Android: Add intent filters in AndroidManifest.xml (already configured)
-- iOS: Add URL schemes in Info.plist (already configured)
-- Web: Add protocol handlers in manifest.json (already configured)