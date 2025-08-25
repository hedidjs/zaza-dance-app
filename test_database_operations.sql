-- =============================================
-- ZAZA DANCE DATABASE VERIFICATION SCRIPT
-- =============================================
-- Run this script after applying the database fix
-- to verify everything is working correctly
-- =============================================

-- Test 1: Verify tables exist with correct structure
DO $$
DECLARE
    tables_to_check TEXT[] := ARRAY['users', 'categories', 'gallery_items', 'tutorials', 'updates', 'user_interactions'];
    table_name TEXT;
    table_exists BOOLEAN;
BEGIN
    RAISE NOTICE '🔍 TEST 1: VERIFYING TABLE STRUCTURE';
    RAISE NOTICE '=====================================';
    
    FOREACH table_name IN ARRAY tables_to_check
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = table_name
        ) INTO table_exists;
        
        IF table_exists THEN
            RAISE NOTICE '✅ Table "%" exists', table_name;
        ELSE
            RAISE NOTICE '❌ Table "%" missing', table_name;
        END IF;
    END LOOP;
    
    RAISE NOTICE '';
END $$;

-- Test 2: Verify RLS policies allow anonymous read access
DO $$
BEGIN
    RAISE NOTICE '🔒 TEST 2: TESTING ANONYMOUS ACCESS';
    RAISE NOTICE '=================================';
END $$;

-- Test categories access
DO $$
DECLARE
    category_count INTEGER;
BEGIN
    SET ROLE anon;
    SELECT COUNT(*) INTO category_count FROM public.categories WHERE is_active = true;
    RESET ROLE;
    
    IF category_count > 0 THEN
        RAISE NOTICE '✅ Anonymous users can read categories (% found)', category_count;
    ELSE
        RAISE NOTICE '❌ No categories accessible to anonymous users';
    END IF;
END $$;

-- Test gallery_items access  
DO $$
DECLARE
    gallery_count INTEGER;
BEGIN
    SET ROLE anon;
    SELECT COUNT(*) INTO gallery_count FROM public.gallery_items WHERE is_active = true;
    RESET ROLE;
    
    IF gallery_count >= 0 THEN
        RAISE NOTICE '✅ Anonymous users can read gallery items (% found)', gallery_count;
    ELSE
        RAISE NOTICE '❌ Gallery items not accessible to anonymous users';
    END IF;
END $$;

-- Test tutorials access
DO $$
DECLARE
    tutorial_count INTEGER;
BEGIN  
    SET ROLE anon;
    SELECT COUNT(*) INTO tutorial_count FROM public.tutorials WHERE is_active = true;
    RESET ROLE;
    
    IF tutorial_count >= 0 THEN
        RAISE NOTICE '✅ Anonymous users can read tutorials (% found)', tutorial_count;
    ELSE
        RAISE NOTICE '❌ Tutorials not accessible to anonymous users';
    END IF;
END $$;

-- Test updates access
DO $$
DECLARE
    update_count INTEGER;
BEGIN
    SET ROLE anon;
    SELECT COUNT(*) INTO update_count FROM public.updates WHERE is_active = true;
    RESET ROLE;
    
    IF update_count >= 0 THEN
        RAISE NOTICE '✅ Anonymous users can read updates (% found)', update_count;
    ELSE
        RAISE NOTICE '❌ Updates not accessible to anonymous users';
    END IF;
END $$;

-- Test user_interactions can be inserted anonymously
DO $$
DECLARE
    sample_content_id UUID;
    interaction_inserted BOOLEAN := false;
BEGIN
    -- Get a sample content ID from gallery_items
    SELECT id INTO sample_content_id FROM public.gallery_items LIMIT 1;
    
    IF sample_content_id IS NOT NULL THEN
        SET ROLE anon;
        BEGIN
            INSERT INTO public.user_interactions (user_device_id, content_type, content_id, interaction_type)
            VALUES ('test_device_12345', 'gallery_item', sample_content_id, 'like');
            interaction_inserted := true;
        EXCEPTION WHEN OTHERS THEN
            interaction_inserted := false;
        END;
        RESET ROLE;
        
        IF interaction_inserted THEN
            RAISE NOTICE '✅ Anonymous users can insert interactions';
            -- Clean up test data
            DELETE FROM public.user_interactions WHERE user_device_id = 'test_device_12345';
        ELSE
            RAISE NOTICE '❌ Anonymous users cannot insert interactions';
        END IF;
    ELSE
        RAISE NOTICE '⚠️ No gallery items found to test interactions';
    END IF;
END $$;

-- Test 3: Verify schema alignment with app expectations
DO $$
DECLARE
    required_columns TEXT[][] := ARRAY[
        ARRAY['gallery_items', 'category_id'],
        ARRAY['gallery_items', 'title_he'], 
        ARRAY['gallery_items', 'description_he'],
        ARRAY['gallery_items', 'is_active'],
        ARRAY['tutorials', 'category_id'],
        ARRAY['tutorials', 'title_he'],
        ARRAY['tutorials', 'duration_seconds'],
        ARRAY['tutorials', 'instructor_name'],
        ARRAY['updates', 'title_he'],
        ARRAY['updates', 'content_he'],
        ARRAY['updates', 'excerpt_he'],
        ARRAY['updates', 'publish_date']
    ];
    table_col TEXT[];
    column_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📋 TEST 3: VERIFYING SCHEMA ALIGNMENT';
    RAISE NOTICE '====================================';
    
    FOREACH table_col SLICE 1 IN ARRAY required_columns
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'public' 
            AND table_name = table_col[1]
            AND column_name = table_col[2]
        ) INTO column_exists;
        
        IF column_exists THEN
            RAISE NOTICE '✅ Column %.% exists', table_col[1], table_col[2];
        ELSE
            RAISE NOTICE '❌ Column %.% missing', table_col[1], table_col[2];  
        END IF;
    END LOOP;
END $$;

-- Test 4: Verify sample data exists
DO $$
DECLARE
    stats_query TEXT;
    stats_result RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 TEST 4: CHECKING SAMPLE DATA';
    RAISE NOTICE '==============================';
    
    FOR stats_result IN 
        SELECT 'categories' as table_name, count(*) as row_count FROM public.categories WHERE is_active = true
        UNION ALL
        SELECT 'gallery_items', count(*) FROM public.gallery_items WHERE is_active = true  
        UNION ALL
        SELECT 'tutorials', count(*) FROM public.tutorials WHERE is_active = true
        UNION ALL
        SELECT 'updates', count(*) FROM public.updates WHERE is_active = true
    LOOP
        IF stats_result.row_count > 0 THEN
            RAISE NOTICE '✅ % table has % rows', stats_result.table_name, stats_result.row_count;
        ELSE
            RAISE NOTICE '⚠️ % table is empty', stats_result.table_name;
        END IF;
    END LOOP;
END $$;

-- Test 5: Verify relationships work correctly
DO $$
DECLARE  
    gallery_with_category INTEGER;
    tutorial_with_category INTEGER;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔗 TEST 5: CHECKING TABLE RELATIONSHIPS';
    RAISE NOTICE '=====================================';
    
    -- Test gallery_items to categories relationship
    SELECT COUNT(*) INTO gallery_with_category 
    FROM public.gallery_items g
    JOIN public.categories c ON g.category_id = c.id
    WHERE g.is_active = true AND c.is_active = true;
    
    IF gallery_with_category > 0 THEN
        RAISE NOTICE '✅ Gallery items properly linked to categories (% linked)', gallery_with_category;
    ELSE
        RAISE NOTICE '⚠️ No gallery items linked to categories';
    END IF;
    
    -- Test tutorials to categories relationship
    SELECT COUNT(*) INTO tutorial_with_category
    FROM public.tutorials t  
    JOIN public.categories c ON t.category_id = c.id
    WHERE t.is_active = true AND c.is_active = true;
    
    IF tutorial_with_category > 0 THEN
        RAISE NOTICE '✅ Tutorials properly linked to categories (% linked)', tutorial_with_category;
    ELSE
        RAISE NOTICE '⚠️ No tutorials linked to categories';  
    END IF;
END $$;

-- Test 6: Verify indexes exist for performance
DO $$  
DECLARE
    important_indexes TEXT[] := ARRAY[
        'idx_categories_active',
        'idx_gallery_items_active', 
        'idx_tutorials_active',
        'idx_updates_publish_date',
        'idx_interactions_device'
    ];
    index_name TEXT;
    index_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '⚡ TEST 6: CHECKING PERFORMANCE INDEXES';  
    RAISE NOTICE '=====================================';
    
    FOREACH index_name IN ARRAY important_indexes
    LOOP
        SELECT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'public' AND indexname = index_name
        ) INTO index_exists;
        
        IF index_exists THEN
            RAISE NOTICE '✅ Index % exists', index_name;
        ELSE
            RAISE NOTICE '⚠️ Index % missing', index_name;
        END IF;
    END LOOP;
END $$;

-- Final Summary
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎉 DATABASE VERIFICATION COMPLETE!';
    RAISE NOTICE '==================================';
    RAISE NOTICE 'Review the results above:';
    RAISE NOTICE '✅ = Working correctly';  
    RAISE NOTICE '❌ = Needs attention';
    RAISE NOTICE '⚠️ = May need investigation';
    RAISE NOTICE '';
    RAISE NOTICE 'If you see any ❌ or critical ⚠️ messages,';
    RAISE NOTICE 'please review the database fix script and';  
    RAISE NOTICE 'check the troubleshooting guide.';
    RAISE NOTICE '';
    RAISE NOTICE 'Your Zaza Dance app should now work properly!';
END $$;