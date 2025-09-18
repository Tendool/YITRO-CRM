UPDATE user_profiles SET role = 'ADMIN' WHERE role IN ('admin', 'Admin');
UPDATE user_profiles SET role = 'USER' WHERE role IN ('user', 'User');
UPDATE user_profiles SET role = 'SALES_MANAGER' WHERE role IN ('sales_manager', 'Sales Manager');
UPDATE user_profiles SET role = 'SALES_REP' WHERE role IN ('sales_rep', 'Sales Rep');
UPDATE user_profiles SET role = 'USER' WHERE role IS NULL;
