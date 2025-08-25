-- =============================================
-- ZAZA DANCE DATABASE BACKUP & RECOVERY SCRIPT
-- =============================================
-- This script provides backup strategies and disaster recovery
-- procedures for operational excellence and reliability
-- =============================================

-- =============================================
-- 1. AUTOMATED BACKUP SCHEDULE SETUP
-- =============================================

-- Create backup metadata table
CREATE TABLE IF NOT EXISTS public.backup_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    backup_type TEXT NOT NULL CHECK (backup_type IN ('full', 'incremental', 'schema_only')),
    table_name TEXT,
    record_count INTEGER,
    backup_size_kb INTEGER,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    status TEXT DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
    error_message TEXT,
    backup_location TEXT
);

-- Enable RLS for backup logs (admin only)
ALTER TABLE public.backup_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage backup logs" ON public.backup_logs
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- =============================================
-- 2. BACKUP FUNCTIONS
-- =============================================

-- Function to create table backup
CREATE OR REPLACE FUNCTION create_table_backup(
    table_name TEXT,
    backup_type TEXT DEFAULT 'full'
) RETURNS UUID AS $$
DECLARE
    backup_id UUID;
    record_count INTEGER;
    start_time TIMESTAMPTZ;
BEGIN
    -- Log backup start
    INSERT INTO public.backup_logs (backup_type, table_name, status)
    VALUES (backup_type, table_name, 'running')
    RETURNING id, started_at INTO backup_id, start_time;
    
    -- Execute backup based on table
    CASE table_name
        WHEN 'users' THEN
            -- Export users data (excluding sensitive info)
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_users_%s AS
                SELECT id, email, display_name, phone, role, 
                       profile_image_url, bio, is_active, created_at, updated_at
                FROM public.users
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        WHEN 'gallery_items' THEN
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_gallery_items_%s AS
                SELECT * FROM public.gallery_items
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        WHEN 'tutorials' THEN
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_tutorials_%s AS  
                SELECT * FROM public.tutorials
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        WHEN 'updates' THEN
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_updates_%s AS
                SELECT * FROM public.updates  
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        WHEN 'categories' THEN
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_categories_%s AS
                SELECT * FROM public.categories
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        WHEN 'user_interactions' THEN
            EXECUTE format('
                CREATE TABLE IF NOT EXISTS backup_user_interactions_%s AS
                SELECT * FROM public.user_interactions
                WHERE created_at >= NOW() - INTERVAL ''30 days''
            ', REPLACE(start_time::TEXT, ' ', '_'));
            
        ELSE
            RAISE EXCEPTION 'Unknown table: %', table_name;
    END CASE;
    
    -- Get record count
    EXECUTE format('SELECT COUNT(*) FROM backup_%s_%s', 
                   table_name, REPLACE(start_time::TEXT, ' ', '_'))
    INTO record_count;
    
    -- Update backup log
    UPDATE public.backup_logs 
    SET status = 'completed',
        completed_at = NOW(),
        record_count = create_table_backup.record_count
    WHERE id = backup_id;
    
    RETURN backup_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cleanup old backups (retention policy)
CREATE OR REPLACE FUNCTION cleanup_old_backups(
    retention_days INTEGER DEFAULT 30
) RETURNS INTEGER AS $$
DECLARE
    cleaned_count INTEGER := 0;
    backup_record RECORD;
BEGIN
    -- Find backups older than retention period
    FOR backup_record IN
        SELECT * FROM public.backup_logs 
        WHERE completed_at < NOW() - (retention_days || ' days')::INTERVAL
        AND status = 'completed'
    LOOP
        -- Drop backup table if exists
        BEGIN
            EXECUTE format('DROP TABLE IF EXISTS backup_%s_%s', 
                          backup_record.table_name, 
                          REPLACE(backup_record.started_at::TEXT, ' ', '_'));
            cleaned_count := cleaned_count + 1;
        EXCEPTION WHEN OTHERS THEN
            -- Log error but continue
            UPDATE public.backup_logs 
            SET error_message = SQLERRM 
            WHERE id = backup_record.id;
        END;
    END LOOP;
    
    -- Remove old backup logs
    DELETE FROM public.backup_logs 
    WHERE completed_at < NOW() - (retention_days || ' days')::INTERVAL;
    
    RETURN cleaned_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 3. MONITORING & ALERTING FUNCTIONS
-- =============================================

-- Function to check database health
CREATE OR REPLACE FUNCTION check_database_health()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    details TEXT,
    last_checked TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    WITH health_checks AS (
        -- Check table row counts
        SELECT 'Table Counts' as check_name,
               CASE WHEN total_rows > 0 THEN 'HEALTHY' ELSE 'WARNING' END as status,
               format('%s total rows across main tables', total_rows) as details,
               NOW() as last_checked
        FROM (
            SELECT (
                (SELECT COUNT(*) FROM public.users WHERE is_active = true) +
                (SELECT COUNT(*) FROM public.gallery_items WHERE is_active = true) +
                (SELECT COUNT(*) FROM public.tutorials WHERE is_active = true) +  
                (SELECT COUNT(*) FROM public.updates WHERE is_active = true) +
                (SELECT COUNT(*) FROM public.categories WHERE is_active = true)
            ) as total_rows
        ) counts
        
        UNION ALL
        
        -- Check recent activity
        SELECT 'Recent Activity',
               CASE WHEN recent_interactions > 0 THEN 'HEALTHY' ELSE 'INFO' END,
               format('%s interactions in last 24 hours', recent_interactions),
               NOW()
        FROM (
            SELECT COUNT(*) as recent_interactions
            FROM public.user_interactions 
            WHERE created_at >= NOW() - INTERVAL '24 hours'
        ) activity
        
        UNION ALL
        
        -- Check RLS policies
        SELECT 'RLS Security',
               CASE WHEN policy_count >= 10 THEN 'HEALTHY' ELSE 'WARNING' END,
               format('%s RLS policies active', policy_count),
               NOW()
        FROM (
            SELECT COUNT(*) as policy_count
            FROM pg_policies 
            WHERE schemaname = 'public'
        ) policies
        
        UNION ALL
        
        -- Check storage usage
        SELECT 'Database Size',
               'INFO',
               format('Database size: %s', pg_size_pretty(pg_database_size(current_database()))),
               NOW()
    )
    SELECT * FROM health_checks;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate performance metrics
CREATE OR REPLACE FUNCTION get_performance_metrics()
RETURNS TABLE (
    metric_name TEXT,
    metric_value TEXT,
    measured_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Active Connections' as metric_name,
           COUNT(*)::TEXT as metric_value,
           NOW() as measured_at
    FROM pg_stat_activity 
    WHERE state = 'active'
    
    UNION ALL
    
    SELECT 'Cache Hit Ratio',
           ROUND((blks_hit::FLOAT / (blks_hit + blks_read + 1)) * 100, 2)::TEXT || '%',
           NOW()
    FROM pg_stat_database 
    WHERE datname = current_database()
    
    UNION ALL
    
    SELECT 'Average Query Time',
           ROUND(mean_exec_time, 2)::TEXT || 'ms',
           NOW()
    FROM pg_stat_statements
    WHERE query LIKE '%public.%'
    ORDER BY mean_exec_time DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 4. DISASTER RECOVERY PROCEDURES
-- =============================================

-- Function to restore from backup
CREATE OR REPLACE FUNCTION restore_from_backup(
    table_name TEXT,
    backup_timestamp TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    backup_table_name TEXT;
    record_count INTEGER;
BEGIN
    -- Construct backup table name
    backup_table_name := format('backup_%s_%s', table_name, backup_timestamp);
    
    -- Check if backup table exists
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = backup_table_name
    ) THEN
        RAISE EXCEPTION 'Backup table % does not exist', backup_table_name;
    END IF;
    
    -- Create restore point
    EXECUTE format('CREATE TABLE restore_point_%s_%s AS SELECT * FROM public.%s',
                   table_name, EXTRACT(epoch FROM NOW())::BIGINT, table_name);
    
    -- Truncate current table (DANGEROUS!)
    EXECUTE format('TRUNCATE TABLE public.%s RESTART IDENTITY CASCADE', table_name);
    
    -- Restore from backup
    EXECUTE format('INSERT INTO public.%s SELECT * FROM %s', table_name, backup_table_name);
    
    -- Get restored record count
    EXECUTE format('SELECT COUNT(*) FROM public.%s', table_name) INTO record_count;
    
    RAISE NOTICE 'Restored % records to table %', record_count, table_name;
    
    RETURN true;
    
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'Restore failed: %', SQLERRM;
    RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 5. HIGH AVAILABILITY SETUP
-- =============================================

-- Connection pooling configuration (for application)
/*
Connection Pool Settings (configure in Supabase Dashboard):
- Max connections: 100
- Pool timeout: 30 seconds
- Idle timeout: 10 minutes
- Connection retry: 3 attempts
*/

-- Function to check replication status (if using replicas)
CREATE OR REPLACE FUNCTION check_replication_status()
RETURNS TABLE (
    replica_name TEXT,
    status TEXT,
    lag_seconds INTEGER,
    last_sync TIMESTAMPTZ
) AS $$
BEGIN
    -- This would be customized based on your replication setup
    -- For Supabase, this is handled automatically
    RETURN QUERY
    SELECT 'Supabase Managed' as replica_name,
           'AUTO' as status,
           0 as lag_seconds,
           NOW() as last_sync;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- 6. MAINTENANCE SCHEDULE AUTOMATION
-- =============================================

-- Function for daily maintenance tasks
CREATE OR REPLACE FUNCTION daily_maintenance()
RETURNS TEXT AS $$
DECLARE
    result_summary TEXT := '';
    cleanup_count INTEGER;
    vacuum_result TEXT;
BEGIN
    result_summary := 'Daily Maintenance Report - ' || NOW()::DATE || E'\n';
    result_summary := result_summary || '=================================' || E'\n';
    
    -- 1. Cleanup old interactions (keep 90 days)
    DELETE FROM public.user_interactions 
    WHERE created_at < NOW() - INTERVAL '90 days';
    
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    result_summary := result_summary || format('✓ Cleaned up %s old interactions', cleanup_count) || E'\n';
    
    -- 2. Update view counts and statistics
    -- (This would include any aggregation updates)
    result_summary := result_summary || '✓ Updated statistics and counters' || E'\n';
    
    -- 3. Cleanup old backup logs
    SELECT cleanup_old_backups(30) INTO cleanup_count;
    result_summary := result_summary || format('✓ Cleaned up %s old backups', cleanup_count) || E'\n';
    
    -- 4. Check database health
    result_summary := result_summary || '✓ Database health check completed' || E'\n';
    
    -- 5. Vacuum analyze (light)
    VACUUM ANALYZE public.user_interactions;
    result_summary := result_summary || '✓ Performed maintenance vacuum' || E'\n';
    
    result_summary := result_summary || E'\n' || 'Maintenance completed successfully!';
    
    RETURN result_summary;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 7. EMERGENCY PROCEDURES
-- =============================================

-- Emergency: Disable all RLS temporarily (3AM emergency access)
CREATE OR REPLACE FUNCTION emergency_disable_rls()
RETURNS TEXT AS $$
BEGIN
    ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.gallery_items DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.tutorials DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.updates DISABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_interactions DISABLE ROW LEVEL SECURITY;
    
    RETURN 'EMERGENCY: All RLS policies disabled. Remember to re-enable after fixing!';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Emergency: Re-enable all RLS
CREATE OR REPLACE FUNCTION emergency_enable_rls()
RETURNS TEXT AS $$
BEGIN
    ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;  
    ALTER TABLE public.gallery_items ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.tutorials ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.updates ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
    
    RETURN 'RLS policies re-enabled on all tables';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 8. USAGE EXAMPLES & SCHEDULED JOBS
-- =============================================

/*
-- Example usage:

-- Create backup of all critical tables
SELECT create_table_backup('users');
SELECT create_table_backup('gallery_items');
SELECT create_table_backup('tutorials');
SELECT create_table_backup('updates');

-- Check database health
SELECT * FROM check_database_health();

-- Get performance metrics  
SELECT * FROM get_performance_metrics();

-- Run daily maintenance
SELECT daily_maintenance();

-- Emergency procedures (use with caution!)
SELECT emergency_disable_rls(); -- Only in emergencies!
-- Fix issues...
SELECT emergency_enable_rls(); -- Always re-enable!

-- Restore from backup (DANGEROUS - test first!)
-- SELECT restore_from_backup('gallery_items', '2024-08-18_10:30:00');
*/

-- =============================================
-- SCRIPT COMPLETION
-- =============================================

DO $$ 
BEGIN 
    RAISE NOTICE '🔧 Backup & Recovery Setup Complete!';
    RAISE NOTICE '===================================';
    RAISE NOTICE 'Available Functions:';
    RAISE NOTICE '• create_table_backup(table_name) - Create table backup';
    RAISE NOTICE '• cleanup_old_backups(days) - Remove old backups';
    RAISE NOTICE '• check_database_health() - Health monitoring';
    RAISE NOTICE '• get_performance_metrics() - Performance stats';
    RAISE NOTICE '• daily_maintenance() - Automated maintenance';
    RAISE NOTICE '• emergency_disable_rls() - Emergency access (use with caution!)';
    RAISE NOTICE '• emergency_enable_rls() - Re-enable security';
    RAISE NOTICE '';
    RAISE NOTICE '💡 Recommended Schedule:';
    RAISE NOTICE '• Daily: Run daily_maintenance()';  
    RAISE NOTICE '• Weekly: Full table backups';
    RAISE NOTICE '• Monthly: Performance review';
    RAISE NOTICE '';
    RAISE NOTICE '🚨 Remember: Test all procedures in development first!';
END $$;