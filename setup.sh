#!/bin/bash

# Zaza Dance App - Supabase Setup Script

echo "🕺 Setting up Zaza Dance App Database..."

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI is not installed."
    echo "Please install it first: https://supabase.com/docs/guides/cli"
    exit 1
fi

echo "✅ Supabase CLI found"

# Initialize Supabase project if not already initialized
if [ ! -f "supabase/config.toml" ]; then
    echo "🚀 Initializing Supabase project..."
    supabase init
    
    # Copy our custom config
    cp supabase/config.toml supabase/config.toml.backup
    echo "📝 Custom config applied"
else
    echo "✅ Supabase project already initialized"
fi

# Start local Supabase
echo "🚀 Starting local Supabase services..."
supabase start

# Wait a moment for services to start
sleep 3

# Run migrations
echo "📊 Running database migrations..."
supabase db reset

echo ""
echo "🎉 Setup complete!"
echo ""
echo "🌐 Local services running at:"
echo "   Studio: http://localhost:54330"
echo "   API: http://localhost:54321"
echo "   Auth: http://localhost:54322"
echo ""
echo "📝 Next steps:"
echo "   1. Open Supabase Studio: http://localhost:54330"
echo "   2. Check the users, gallery, tutorials, and updates tables"
echo "   3. Test the sample data (optional migration included)"
echo ""
echo "💡 To stop services: supabase stop"
echo "💡 To link to production: supabase link --project-ref YOUR_PROJECT_REF"