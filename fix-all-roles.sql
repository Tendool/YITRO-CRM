-- First, let's see what we have
PRAGMA table_info(user_profiles);

-- Update all role values to proper enum format
UPDATE user_profiles SET role = 'ADMIN' WHERE role = 'Admin';
UPDATE user_profiles SET role = 'ADMIN' WHERE role = 'admin';
UPDATE user_profiles SET role = 'USER' WHERE role = 'User';
UPDATE user_profiles SET role = 'USER' WHERE role = 'user';
UPDATE user_profiles SET role = 'SALES_MANAGER' WHERE role = 'Sales Manager';
UPDATE user_profiles SET role = 'SALES_MANAGER' WHERE role = 'sales_manager';
UPDATE user_profiles SET role = 'SALES_REP' WHERE role = 'Sales Rep';
UPDATE user_profiles SET role = 'SALES_REP' WHERE role = 'sales_rep';

-- Set any NULL or invalid roles to USER
UPDATE user_profiles SET role = 'USER' WHERE role IS NULL OR role NOT IN ('ADMIN', 'USER', 'SALES_MANAGER', 'SALES_REP');

-- Show final results
SELECT role, COUNT(*) as count FROM user_profiles GROUP BY role;
