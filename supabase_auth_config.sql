-- Supabase Auth Configuration for zazadance.com Domain
-- This script configures the redirect URLs for email confirmation

-- Note: These settings need to be configured in Supabase Dashboard
-- Go to Authentication > URL Configuration

-- Site URL (Main domain): https://zazadance.com
-- Additional redirect URLs:
-- https://zazadance.com/auth/callback
-- https://zazadance.com/welcome
-- com.zazadance.zazaDance://auth/callback (for mobile deep links)
-- com.zazadance.zazaDance://welcome (for mobile deep links)

-- Email Templates Configuration:
-- Confirmation Email: https://zazadance.com/auth/confirm?token={{ .Token }}
-- Reset Password: https://zazadance.com/auth/reset?token={{ .Token }}
-- Magic Link: https://zazadance.com/auth/magic?token={{ .Token }}

-- Custom SMTP Settings (if needed):
-- SMTP Host: Your email provider's SMTP host
-- SMTP Port: 587 (TLS) or 465 (SSL)
-- SMTP User: Your email address
-- SMTP Pass: Your email password or app password

-- Instructions:
-- 1. Go to Supabase Dashboard > Authentication > URL Configuration
-- 2. Set Site URL to: https://zazadance.com
-- 3. Add redirect URLs listed above
-- 4. Go to Authentication > Email Templates
-- 5. Update confirmation email template with correct redirect URL
-- 6. Test email confirmation flow

-- For development, you can also add:
-- http://localhost:3000 (for web development)
-- Additional URLs as needed