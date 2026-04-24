-- =====================================================
-- Gen Z Quiz App - Database Schema
-- =====================================================

-- =====================================================
-- 1. TABLES PRINCIPALES
-- =====================================================

-- Table pour les résultats de QCM
CREATE TABLE IF NOT EXISTS quiz_results (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  category text,
  total_questions int,
  correct_answers int,
  score int,
  duration_seconds int,
  created_at timestamp with time zone DEFAULT now()
);

-- Table pour les statistiques utilisateur
CREATE TABLE IF NOT EXISTS user_stats (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  total_quizzes int DEFAULT 0,
  total_correct int DEFAULT 0,
  total_questions int DEFAULT 0,
  average_score float DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now()
);

-- Table pour les profils utilisateurs (métadonnées)
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  name text,
  age int,
  moyen_paiement text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- =====================================================
-- 2. FONCTIONS POUR ADMIN
-- =====================================================

-- Fonction pour vérifier si un utilisateur est admin
CREATE OR REPLACE FUNCTION is_admin(user_email text)
RETURNS boolean AS $$
BEGIN
  RETURN user_email IN ('chadareandy@gmail.com', 'deogratiashounnou1@gmail.com');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir tous les utilisateurs (admin only)
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
  id uuid,
  email text,
  created_at timestamp with time zone,
  last_sign_in_at timestamp with time zone,
  user_metadata jsonb,
  is_admin boolean
) AS $$
DECLARE
  current_user_email text;
BEGIN
  -- Récupérer l'email de l'utilisateur connecté
  SELECT email INTO current_user_email FROM auth.users WHERE auth.users.id = auth.uid();
  
  -- Vérifier si admin
  IF NOT is_admin(current_user_email) THEN
    RAISE EXCEPTION 'Accès refusé : Vous devez être administrateur';
  END IF;
  
  RETURN QUERY
  SELECT 
    au.id,
    au.email,
    au.created_at,
    au.last_sign_in_at,
    au.raw_user_meta_data as user_metadata,
    is_admin(au.email) as is_admin
  FROM auth.users au
  ORDER BY au.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir les stats de tous les utilisateurs
CREATE OR REPLACE FUNCTION get_all_users_stats()
RETURNS TABLE (
  user_id uuid,
  email text,
  name text,
  age int,
  total_quizzes bigint,
  total_correct bigint,
  total_questions bigint,
  average_score float,
  last_quiz_date timestamp with time zone
) AS $$
DECLARE
  current_user_email text;
BEGIN
  SELECT email INTO current_user_email FROM auth.users WHERE auth.users.id = auth.uid();
  
  IF NOT is_admin(current_user_email) THEN
    RAISE EXCEPTION 'Accès refusé : Vous devez être administrateur';
  END IF;
  
  RETURN QUERY
  SELECT 
    au.id as user_id,
    au.email,
    COALESCE(up.name, '') as name,
    COALESCE(up.age, 0) as age,
    COALESCE(us.total_quizzes, 0) as total_quizzes,
    COALESCE(us.total_correct, 0) as total_correct,
    COALESCE(us.total_questions, 0) as total_questions,
    COALESCE(us.average_score, 0) as average_score,
    us.updated_at as last_quiz_date
  FROM auth.users au
  LEFT JOIN user_profiles up ON up.user_id = au.id
  LEFT JOIN user_stats us ON us.user_id = au.id
  ORDER BY au.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour supprimer un utilisateur (admin only)
CREATE OR REPLACE FUNCTION delete_user(target_user_id uuid)
RETURNS void AS $$
DECLARE
  current_user_email text;
BEGIN
  SELECT email INTO current_user_email FROM auth.users WHERE auth.users.id = auth.uid();
  
  IF NOT is_admin(current_user_email) THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;
  
  -- Supprimer d'abord les données liées
  DELETE FROM quiz_results WHERE user_id = target_user_id;
  DELETE FROM user_stats WHERE user_id = target_user_id;
  DELETE FROM user_profiles WHERE user_id = target_user_id;
  
  -- Supprimer l'utilisateur de auth.users
  DELETE FROM auth.users WHERE id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir tous les résultats de QCM (admin only)
CREATE OR REPLACE FUNCTION get_all_quiz_results()
RETURNS TABLE (
  result_id uuid,
  user_id uuid,
  email text,
  category text,
  total_questions int,
  correct_answers int,
  score int,
  duration_seconds int,
  created_at timestamp with time zone
) AS $$
DECLARE
  current_user_email text;
BEGIN
  SELECT email INTO current_user_email FROM auth.users WHERE auth.users.id = auth.uid();
  
  IF NOT is_admin(current_user_email) THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;
  
  RETURN QUERY
  SELECT 
    qr.id as result_id,
    qr.user_id,
    au.email,
    qr.category,
    qr.total_questions,
    qr.correct_answers,
    qr.score,
    qr.duration_seconds,
    qr.created_at
  FROM quiz_results qr
  JOIN auth.users au ON au.id = qr.user_id
  ORDER BY qr.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir les statistiques globales (admin only)
CREATE OR REPLACE FUNCTION get_global_stats()
RETURNS TABLE (
  total_users bigint,
  total_quizzes bigint,
  total_questions_answered bigint,
  average_score_global float,
  best_user_email text,
  best_user_score float
) AS $$
DECLARE
  current_user_email text;
BEGIN
  SELECT email INTO current_user_email FROM auth.users WHERE auth.users.id = auth.uid();
  
  IF NOT is_admin(current_user_email) THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;
  
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*) FROM auth.users) as total_users,
    (SELECT COALESCE(SUM(total_quizzes), 0) FROM user_stats) as total_quizzes,
    (SELECT COALESCE(SUM(total_questions), 0) FROM user_stats) as total_questions_answered,
    (SELECT COALESCE(AVG(average_score), 0) FROM user_stats) as average_score_global,
    (SELECT au.email 
     FROM user_stats us 
     JOIN auth.users au ON au.id = us.user_id 
     ORDER BY us.average_score DESC 
     LIMIT 1) as best_user_email,
    (SELECT COALESCE(MAX(average_score), 0) FROM user_stats) as best_user_score;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. TRIGGERS
-- =====================================================

-- Trigger pour créer automatiquement un profil utilisateur
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (user_id, name, age)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'name', NULL);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();

-- =====================================================
-- 4. INDEX POUR PERFORMANCES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_quiz_results_user_id ON quiz_results(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_results_created_at ON quiz_results(created_at);
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);

-- =====================================================
-- 5. ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Activer RLS sur toutes les tables
ALTER TABLE quiz_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Politiques pour quiz_results
DROP POLICY IF EXISTS "Users can see their own quiz results" ON quiz_results;
CREATE POLICY "Users can see their own quiz results"
  ON quiz_results FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own quiz results" ON quiz_results;
CREATE POLICY "Users can insert their own quiz results"
  ON quiz_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Politiques pour user_stats
DROP POLICY IF EXISTS "Users can see their own stats" ON user_stats;
CREATE POLICY "Users can see their own stats"
  ON user_stats FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own stats" ON user_stats;
CREATE POLICY "Users can update their own stats"
  ON user_stats FOR UPDATE
  USING (auth.uid() = user_id);

-- Politiques pour user_profiles
DROP POLICY IF EXISTS "Users can see their own profile" ON user_profiles;
CREATE POLICY "Users can see their own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
CREATE POLICY "Users can update their own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
