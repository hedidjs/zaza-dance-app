-- Row Level Security (RLS) Policies for Zaza Dance App

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE updates ENABLE ROW LEVEL SECURITY;

-- Users table policies
-- Users can read their own profile and other users' basic info
CREATE POLICY "Users can view profiles" ON users
  FOR SELECT USING (TRUE);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Only admins can insert/delete users (registration handled by auth)
CREATE POLICY "Admins can insert users" ON users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete users" ON users
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Gallery table policies
-- Everyone can view gallery items
CREATE POLICY "Anyone can view gallery" ON gallery
  FOR SELECT USING (TRUE);

-- Instructors and admins can manage gallery
CREATE POLICY "Instructors and admins can insert gallery" ON gallery
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors and admins can update gallery" ON gallery
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors and admins can delete gallery" ON gallery
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

-- Tutorials table policies
-- Everyone can view published tutorials
CREATE POLICY "Anyone can view published tutorials" ON tutorials
  FOR SELECT USING (is_published = TRUE OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

-- Instructors can manage their own tutorials, admins can manage all
CREATE POLICY "Instructors can insert tutorials" ON tutorials
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Instructors can update own tutorials" ON tutorials
  FOR UPDATE USING (
    instructor_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Instructors can delete own tutorials" ON tutorials
  FOR DELETE USING (
    instructor_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Updates table policies
-- Everyone can view published updates
CREATE POLICY "Anyone can view published updates" ON updates
  FOR SELECT USING (is_published = TRUE OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

-- Instructors and admins can manage updates
CREATE POLICY "Instructors and admins can insert updates" ON updates
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    )
  );

CREATE POLICY "Authors and admins can update updates" ON updates
  FOR UPDATE USING (
    author_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Authors and admins can delete updates" ON updates
  FOR DELETE USING (
    author_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );