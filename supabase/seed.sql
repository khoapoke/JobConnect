-- ============================================================
-- JobConnect — Comprehensive Local Seed Data
-- Run: supabase db reset  (applies after all migrations)
--
-- Accounts (all passwords = "password123"):
--   admin@jobconnect.local      — Admin
--   recruiter1@jobconnect.local — ABC Technology
--   recruiter2@jobconnect.local — XYZ Solutions
--   recruiter3@jobconnect.local — Innovate Lab
--   seeker1..6@jobconnect.local — 6 seekers with rich profiles
-- ============================================================

-- --------------------------------------------------------------
-- 1. Disable role-immutable trigger so we can set admin role
-- --------------------------------------------------------------
ALTER TABLE profiles DISABLE TRIGGER enforce_role_immutable;

-- --------------------------------------------------------------
-- 2. Auth users  (profiles auto-created by on_auth_user_created)
-- --------------------------------------------------------------
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data)
VALUES
  -- Admin
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'admin@jobconnect.local',      crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"admin",   "full_name":"Admin JobConnect"}'::jsonb),
  -- Recruiters
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'recruiter1@jobconnect.local', crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"recruiter","full_name":"Nguyễn Thị Hoa"}'::jsonb),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'recruiter2@jobconnect.local', crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"recruiter","full_name":"Trần Văn Nam"}'::jsonb),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'recruiter3@jobconnect.local', crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"recruiter","full_name":"Lê Thị Hồng"}'::jsonb),
  -- Seekers
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker1@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Nguyễn Văn An"}'::jsonb),
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker2@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Trần Thị Bình"}'::jsonb),
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker3@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Lê Văn Cường"}'::jsonb),
  ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker4@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Phạm Thị Dung"}'::jsonb),
  ('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker5@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Hoàng Văn Em"}'::jsonb),
  ('30000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'seeker6@jobconnect.local',  crypt('password123', gen_salt('bf')), now(), now(), now(), '{"role":"seeker",  "full_name":"Đỗ Thị Phương"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 3. Enrich profiles
-- --------------------------------------------------------------
UPDATE profiles SET role = 'admin',   full_name = 'Admin JobConnect',    bio = 'Quản trị viên hệ thống JobConnect.',                              location = 'Hồ Chí Minh', headline = 'System Administrator',           is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin'   WHERE id = '10000000-0000-0000-0000-000000000001';
UPDATE profiles SET role = 'recruiter', full_name = 'Nguyễn Thị Hoa',      bio = 'HR Manager tại ABC Technology. Tìm kiếm tài năng công nghệ.',      location = 'Hồ Chí Minh', headline = 'HR Manager @ ABC Technology',    is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=hr1'      WHERE id = '20000000-0000-0000-0000-000000000001';
UPDATE profiles SET role = 'recruiter', full_name = 'Trần Văn Nam',       bio = 'Tech Lead & Hiring Manager tại XYZ Solutions.',                    location = 'Hà Nội',      headline = 'Tech Lead @ XYZ Solutions',    is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=hr2'      WHERE id = '20000000-0000-0000-0000-000000000002';
UPDATE profiles SET role = 'recruiter', full_name = 'Lê Thị Hồng',       bio = 'Founder Innovate Lab. Đam mê xây dựng đội ngũ sáng tạo.',          location = 'Đà Nẵng',     headline = 'Founder @ Innovate Lab',       is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=hr3'      WHERE id = '20000000-0000-0000-0000-000000000003';
UPDATE profiles SET role = 'seeker',    full_name = 'Nguyễn Văn An',       bio = 'Lập trình viên Flutter đam mê xây dựng ứng dụng mobile đa nền tảng.', location = 'Hồ Chí Minh', headline = 'Flutter Developer | 3 năm kinh nghiệm', is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker1'   WHERE id = '30000000-0000-0000-0000-000000000001';
UPDATE profiles SET role = 'seeker',    full_name = 'Trần Thị Bình',       bio = 'Designer yêu thích tạo ra trải nghiệm người dùng trực quan và đẹp mắt.', location = 'Hà Nội',    headline = 'UI/UX Designer | Figma & Adobe',   is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker2'   WHERE id = '30000000-0000-0000-0000-000000000002';
UPDATE profiles SET role = 'seeker',    full_name = 'Lê Văn Cường',        bio = 'Kỹ sư backend chuyên xây dựng API scalable và hệ thống microservices.', location = 'Hồ Chí Minh', headline = 'Backend Developer | Node.js, Python, PostgreSQL', is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker3' WHERE id = '30000000-0000-0000-0000-000000000003';
UPDATE profiles SET role = 'seeker',    full_name = 'Phạm Thị Dung',       bio = 'Phân tích dữ liệu để đưa ra insights kinh doanh giá trị.',         location = 'Đà Nẵng',     headline = 'Data Analyst | SQL, Python, Power BI', is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker4' WHERE id = '30000000-0000-0000-0000-000000000004';
UPDATE profiles SET role = 'seeker',    full_name = 'Hoàng Văn Em',        bio = 'Quản lý sản phẩm với nền tảng kỹ thuật vững chắc và tư duy kinh doanh.', location = 'Hồ Chí Minh', headline = 'Product Manager | Agile, Scrum', is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker5' WHERE id = '30000000-0000-0000-0000-000000000005';
UPDATE profiles SET role = 'seeker',    full_name = 'Đỗ Thị Phương',       bio = 'Chuyên gia content marketing và SEO với kinh nghiệm đa ngành.',     location = 'Hà Nội',      headline = 'Content Marketing | SEO, Social Media', is_onboarding_complete = true, avatar_url = 'https://api.dicebear.com/7.x/avataaars/svg?seed=seeker6' WHERE id = '30000000-0000-0000-0000-000000000006';

-- Re-enable role immutable trigger
ALTER TABLE profiles ENABLE TRIGGER enforce_role_immutable;

-- --------------------------------------------------------------
-- 4. Companies
-- --------------------------------------------------------------
INSERT INTO companies (id, recruiter_id, name, logo_url, description, website, size, province)
VALUES
  ('40000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'ABC Technology',      'https://placehold.co/100x100/1976D2/FFFFFF?text=ABC', 'Công ty phần mềm hàng đầu tại Việt Nam, chuyên cung cấp giải pháp mobile và web cho doanh nghiệp.', 'https://abctech.vn',      '201-500', 'Hồ Chí Minh'),
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'XYZ Solutions',       'https://placehold.co/100x100/388E3C/FFFFFF?text=XYZ',  'Đối tác công nghệ toàn cầu, cung cấp dịch vụ outsourcing và phát triển phần mềm custom.',           'https://xyzsolutions.com', '501-1000', 'Hà Nội'),
  ('40000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003', 'Innovate Lab',        'https://placehold.co/100x100/F57C00/FFFFFF?text=INN',  'Startup công nghệ tập trung vào AI và data analytics cho thị trường Đông Nam Á.',                    'https://innovatelab.io',   '11-50',    'Đà Nẵng')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 5. Job posts
-- --------------------------------------------------------------
INSERT INTO job_posts (id, company_id, title, description, requirements, salary_min, salary_max, type, category_id, status, expires_at, created_at)
VALUES
  -- ABC Technology
  ('50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', 'Senior Flutter Developer', 'Phát triển ứng dụng mobile Flutter cho khách hàng enterprise. Tham gia thiết kế kiến trúc, review code và mentor junior developer.', '3+ năm kinh nghiệm Flutter. Thành thạo Dart, State management (BLoC/Riverpod). Có kinh nghiệm tích hợp REST API và Firebase.', 25000000, 40000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '5 days'),
  ('50000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001', 'React Native Developer',   'Xây dựng app cross-platform với React Native cho dự án fintech. Phối hợp chặt với design và backend team.', '2+ năm React Native. Thành thạo JavaScript/TypeScript. Có kinh nghiệm Redux/Zustand và tích hợp native module.', 20000000, 35000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '4 days'),
  ('50000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000001', 'Product Owner',            'Điều phối giữa business và dev team. Viết user story, quản lý backlog và đảm bảo sprint goal đạt được.', '3+ năm làm Product Owner/Manager. Hiểu biết về Agile/Scrum. Kỹ năng giao tiếp và phân tích tốt.', 30000000, 45000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '3 days'),
  -- XYZ Solutions
  ('50000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000002', 'UI/UX Designer',           'Thiết kế giao diện cho các sản phẩm SaaS B2B. Nghiên cứu người dùng, lập flow và tạo prototype tương tác.', '2+ năm UI/UX design. Thành thạo Figma. Hiểu biết về design system và accessibility. Có portfolio cụ thể.', 18000000, 28000000, 'hybrid',    (SELECT id FROM job_categories WHERE slug = 'thiet-ke-ui-ux'), 'active', now() + interval '30 days', now() - interval '6 days'),
  ('50000000-0000-0000-0000-000000000005', '40000000-0000-0000-0000-000000000002', 'Backend Node.js Developer', 'Phát triển API RESTful và microservices với Node.js/Express. Tối ưu database query và caching layer.', '3+ năm Node.js. Thành thạo SQL/NoSQL. Kinh nghiệm Docker, Redis và CI/CD là lợi thế.', 22000000, 38000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '2 days'),
  ('50000000-0000-0000-0000-000000000006', '40000000-0000-0000-0000-000000000002', 'Fullstack Developer',      'Phát triển end-to-end cho dự án fintech. Frontend React + backend Node.js. Triển khai trên AWS.', '2+ năm fullstack. Thành thạo React, Node.js và PostgreSQL. Hiểu biết về security và performance.', 25000000, 40000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '1 day'),
  -- Innovate Lab
  ('50000000-0000-0000-0000-000000000007', '40000000-0000-0000-0000-000000000003', 'Data Analyst',             'Phân tích dữ liệu người dùng và thị trường. Xây dựng dashboard báo cáo. Hỗ trợ team product đưa ra quyết định data-driven.', '1+ năm data analysis. Thành thạo Python, SQL và Power BI. Hiểu biết cơ bản về machine learning.', 15000000, 25000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '7 days'),
  ('50000000-0000-0000-0000-000000000008', '40000000-0000-0000-0000-000000000003', 'Junior Flutter Developer', 'Tham gia phát triển app startup với Flutter. Học hỏi từ senior và đóng góp tính năng mới.', 'Có dự án Flutter cá nhân hoặc internship. Biết Dart cơ bản và tích hợp API. Ham học hỏi.', 12000000, 18000000, 'full_time', (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '3 days'),
  ('50000000-0000-0000-0000-000000000009', '40000000-0000-0000-0000-000000000003', 'DevOps Engineer',          'Xây dựng CI/CD pipeline và quản lý hạ tầng cloud (AWS/GCP). Monitor hệ thống và tối ưu chi phí.', '2+ năm DevOps. Kinh nghiệm Docker, Kubernetes, Terraform. Hiểu biết về networking và security.', 20000000, 30000000, 'remote',    (SELECT id FROM job_categories WHERE slug = 'it-phan-mem'), 'active', now() + interval '30 days', now() - interval '2 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 6. Job locations
-- --------------------------------------------------------------
INSERT INTO job_locations (job_id, province, district, address, is_remote)
VALUES
  ('50000000-0000-0000-0000-000000000001', 'Hồ Chí Minh', 'Quận 1', '123 Nguyễn Huệ, Quận 1', false),
  ('50000000-0000-0000-0000-000000000002', 'Hồ Chí Minh', 'Quận 3', '456 Võ Văn Tần, Quận 3', false),
  ('50000000-0000-0000-0000-000000000003', 'Hồ Chí Minh', 'Quận 7', '789 Phú Mỹ Hưng, Quận 7', false),
  ('50000000-0000-0000-0000-000000000004', 'Hà Nội',      'Cầu Giấy', '12 Phố Duy Tân, Cầu Giấy', false),
  ('50000000-0000-0000-0000-000000000005', 'Hà Nội',      'Ba Đình', '45 Phố Kim Mã, Ba Đình', false),
  ('50000000-0000-0000-0000-000000000006', 'Hà Nội',      'Hoàn Kiếm', '78 Phố Tràng Tiền, Hoàn Kiếm', false),
  ('50000000-0000-0000-0000-000000000007', 'Đà Nẵng',     'Hải Châu', '101 Bạch Đằng, Hải Châu', false),
  ('50000000-0000-0000-0000-000000000008', 'Đà Nẵng',     'Sơn Trà', '202 Nguyễn Văn Thoại, Sơn Trà', false),
  ('50000000-0000-0000-0000-000000000009', 'Đà Nẵng',     'Ngũ Hành Sơn', '303 Nguyễn Hữu Thọ, Ngũ Hành Sơn', true)
ON CONFLICT DO NOTHING;

-- --------------------------------------------------------------
-- 7. Job required skills (lookup by skill name)
-- --------------------------------------------------------------
INSERT INTO job_required_skills (job_id, skill_id, is_required)
VALUES
  -- Senior Flutter
  ('50000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Flutter'),      true),
  ('50000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Dart'),         true),
  ('50000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Firebase'),     true),
  ('50000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Git'),         true),
  ('50000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'REST API'),    true),
  -- React Native
  ('50000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'React Native'), true),
  ('50000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'JavaScript'),   true),
  ('50000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'TypeScript'),  true),
  ('50000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'REST API'),    true),
  ('50000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'Git'),         true),
  -- Product Owner
  ('50000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Project Management'), true),
  ('50000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Agile/Scrum'),       true),
  ('50000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Microsoft Office'),  false),
  ('50000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Content Writing'),    false),
  -- UI/UX Designer
  ('50000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Figma'),         true),
  ('50000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'UI/UX Design'),   true),
  ('50000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Adobe XD'),       false),
  ('50000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Photoshop'),      false),
  ('50000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Illustrator'),    false),
  -- Backend Node.js
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Node.js'),       true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'JavaScript'),     true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'TypeScript'),     true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'SQL'),           true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'PostgreSQL'),    true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Docker'),         true),
  ('50000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Git'),          true),
  -- Fullstack
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'React'),         true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Node.js'),       true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'JavaScript'),     true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'TypeScript'),     true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'SQL'),           true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'REST API'),      true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Docker'),         true),
  ('50000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Git'),          true),
  -- Data Analyst
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'Python'),        true),
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'SQL'),           true),
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'Data Analysis'), true),
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'Power BI'),      true),
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'Machine Learning'), false),
  ('50000000-0000-0000-0000-000000000007', (SELECT id FROM skills WHERE name = 'Excel'),         false),
  -- Junior Flutter
  ('50000000-0000-0000-0000-000000000008', (SELECT id FROM skills WHERE name = 'Flutter'),       true),
  ('50000000-0000-0000-0000-000000000008', (SELECT id FROM skills WHERE name = 'Dart'),          true),
  ('50000000-0000-0000-0000-000000000008', (SELECT id FROM skills WHERE name = 'Git'),           true),
  ('50000000-0000-0000-0000-000000000008', (SELECT id FROM skills WHERE name = 'REST API'),     true),
  ('50000000-0000-0000-0000-000000000008', (SELECT id FROM skills WHERE name = 'Firebase'),      false),
  -- DevOps
  ('50000000-0000-0000-0000-000000000009', (SELECT id FROM skills WHERE name = 'Docker'),        true),
  ('50000000-0000-0000-0000-000000000009', (SELECT id FROM skills WHERE name = 'SQL'),          true),
  ('50000000-0000-0000-0000-000000000009', (SELECT id FROM skills WHERE name = 'Git'),          true),
  ('50000000-0000-0000-0000-000000000009', (SELECT id FROM skills WHERE name = 'Python'),        true),
  ('50000000-0000-0000-0000-000000000009', (SELECT id FROM skills WHERE name = 'Node.js'),        false)
ON CONFLICT DO NOTHING;

-- --------------------------------------------------------------
-- 8. User skills
-- --------------------------------------------------------------
INSERT INTO user_skills (user_id, skill_id, level)
VALUES
  -- seeker1: Flutter dev
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Flutter'),      'advanced'),
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Dart'),         'advanced'),
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Firebase'),     'intermediate'),
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'Git'),         'advanced'),
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'REST API'),    'intermediate'),
  ('30000000-0000-0000-0000-000000000001', (SELECT id FROM skills WHERE name = 'UI/UX Design'),  'beginner'),
  -- seeker2: UI/UX
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'Figma'),        'advanced'),
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'UI/UX Design'),  'advanced'),
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'Adobe XD'),      'intermediate'),
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'Photoshop'),     'intermediate'),
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'Illustrator'),   'beginner'),
  ('30000000-0000-0000-0000-000000000002', (SELECT id FROM skills WHERE name = 'HTML/CSS'),     'intermediate'),
  -- seeker3: Backend
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Node.js'),       'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Python'),        'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'SQL'),           'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'PostgreSQL'),    'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Docker'),        'intermediate'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'Git'),           'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'REST API'),      'advanced'),
  ('30000000-0000-0000-0000-000000000003', (SELECT id FROM skills WHERE name = 'JavaScript'),    'intermediate'),
  -- seeker4: Data
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Python'),        'advanced'),
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'SQL'),           'advanced'),
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Data Analysis'), 'advanced'),
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Power BI'),      'intermediate'),
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Machine Learning'),'beginner'),
  ('30000000-0000-0000-0000-000000000004', (SELECT id FROM skills WHERE name = 'Excel'),         'advanced'),
  -- seeker5: PM
  ('30000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Project Management'), 'advanced'),
  ('30000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Agile/Scrum'),       'advanced'),
  ('30000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Microsoft Office'),  'intermediate'),
  ('30000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Content Writing'),    'intermediate'),
  ('30000000-0000-0000-0000-000000000005', (SELECT id FROM skills WHERE name = 'Excel'),              'intermediate'),
  -- seeker6: Marketing
  ('30000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Content Writing'),    'advanced'),
  ('30000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'SEO'),               'advanced'),
  ('30000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Microsoft Office'),   'intermediate'),
  ('30000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Excel'),              'intermediate'),
  ('30000000-0000-0000-0000-000000000006', (SELECT id FROM skills WHERE name = 'Photoshop'),           'beginner')
ON CONFLICT DO NOTHING;

-- --------------------------------------------------------------
-- 9. Work experiences
-- --------------------------------------------------------------
INSERT INTO work_experiences (id, user_id, company, role, from_date, to_date, description, is_current)
VALUES
  ('60000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'TechMobile VN',   'Flutter Developer',       '2022-03-01', '2024-08-01', 'Phát triển app e-commerce với Flutter. Tích hợp Stripe, Firebase Auth và push notification.', false),
  ('60000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'ABC Digital',     'Senior Flutter Developer','2024-09-01', null,         'Dẫn dắt team 3 người phát triển app fintech. Thiết kế architecture với Clean Architecture.', true),
  ('60000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000002', 'DesignHub',       'UI Designer',             '2023-01-01', '2024-05-01', 'Thiết kế UI cho website và app thương mại điện tử. Làm việc với design system.', false),
  ('60000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', 'Creative Studio', 'UI/UX Designer',            '2024-06-01', null,         'End-to-end design cho sản phẩm SaaS B2B. User research, prototype và handoff cho dev.', true),
  ('60000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003', 'SaigonTech',      'Backend Developer',         '2021-06-01', '2023-12-01', 'Xây dựng REST API với Node.js/Express. Quản lý PostgreSQL database và viết complex queries.', false),
  ('60000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', 'CloudSystems',    'Senior Backend Engineer',   '2024-01-01', null,         'Thiết kế microservices với Docker và Kubernetes. Tối ưu performance giảm latency 40%.', true),
  ('60000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000004', 'DataCorp',        'Data Analyst Intern',       '2023-03-01', '2023-09-01', 'Hỗ trợ phân tích dữ liệu sales và xây dựng báo cáo Excel. Học SQL và Python on-the-job.', false),
  ('60000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000004', 'Analytics VN',    'Junior Data Analyst',       '2023-10-01', null,         'Xây dựng dashboard Power BI cho marketing team. Phân tích cohort và churn rate.', true),
  ('60000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000005', 'StartupX',        'Product Owner',             '2022-01-01', '2024-03-01', 'Quản lý roadmap cho app giao hàng. Viết PRD, phối hợp với 2 dev team và design team.', false),
  ('60000000-0000-0000-0000-00000000000a', '30000000-0000-0000-0000-000000000005', 'ProductFirst',    'Senior Product Manager',    '2024-04-01', null,         'Dẫn dắt product line CRM. Tăng retention 25% qua redesign onboarding flow.', true),
  ('60000000-0000-0000-0000-00000000000b', '30000000-0000-0000-0000-000000000006', 'MediaGroup',      'Content Executive',         '2022-07-01', '2024-02-01', 'Viết content cho fanpage và website. Quản lý editorial calendar.', false),
  ('60000000-0000-0000-0000-00000000000c', '30000000-0000-0000-0000-000000000006', 'BrandAgency',     'Content Marketing Specialist', '2024-03-01', null,      'Xây dựng chiến lược content cho 5 khách hàng. Tăng organic traffic 60%.', true)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 10. Educations
-- --------------------------------------------------------------
INSERT INTO educations (id, user_id, school, degree, major, from_date, to_date)
VALUES
  ('70000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'ĐH Bách Khoa HCM',            'Cử nhân', 'Công nghệ thông tin',    '2018-09-01', '2022-06-01'),
  ('70000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'ĐH Mỹ thuật Hà Nội',          'Cử nhân', 'Thiết kế đồ họa',         '2019-09-01', '2023-06-01'),
  ('70000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'ĐH Khoa học Tự nhiên HCM',    'Cử nhân', 'Khoa học máy tính',       '2017-09-01', '2021-06-01'),
  ('70000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', 'ĐH Kinh tế Đà Nẵng',          'Cử nhân', 'Kinh tế học',             '2019-09-01', '2023-06-01'),
  ('70000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', 'ĐH Ngoại thương HCM',         'Cử nhân', 'Quản trị kinh doanh',     '2016-09-01', '2020-06-01'),
  ('70000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', 'Học viện Báo chí & Tuyên truyền', 'Cử nhân', 'Truyền thông',        '2018-09-01', '2022-06-01')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 11. Certificates
-- --------------------------------------------------------------
INSERT INTO certificates (id, user_id, name, issuer, issued_at, credential_url)
VALUES
  ('80000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Flutter Advanced Certification',        'Google',     '2023-05-01', 'https://example.com/cert/flutter-an'),
  ('80000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'Google UX Design Certificate',          'Coursera',   '2023-08-01', 'https://example.com/cert/ux-design'),
  ('80000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'AWS Certified Developer',               'Amazon',     '2024-01-01', 'https://example.com/cert/aws-dev'),
  ('80000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', 'Data Analytics Professional Certificate', 'Google',     '2024-03-01', 'https://example.com/cert/data-pro'),
  ('80000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', 'PSM I',                                 'Scrum.org',  '2022-11-01', 'https://example.com/cert/psm1'),
  ('80000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', 'Google Analytics Certificate',          'Google',     '2023-06-01', 'https://example.com/cert/ga')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 12. Resumes
-- --------------------------------------------------------------
INSERT INTO resumes (id, user_id, title, content_json, file_url, is_default)
VALUES
  ('90000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'CV Flutter Developer',     '{"sections":["experience","education","skills"]}', 'https://example.com/resumes/seeker1.pdf', true),
  ('90000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'CV UI/UX Designer',        '{"sections":["experience","education","portfolio"]}', 'https://example.com/resumes/seeker2.pdf', true),
  ('90000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'CV Backend Developer',     '{"sections":["experience","education","skills","certificates"]}', 'https://example.com/resumes/seeker3.pdf', true),
  ('90000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', 'CV Data Analyst',          '{"sections":["experience","education","skills"]}', 'https://example.com/resumes/seeker4.pdf', true),
  ('90000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', 'CV Product Manager',       '{"sections":["experience","education","skills"]}', 'https://example.com/resumes/seeker5.pdf', true),
  ('90000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', 'CV Content Marketing',   '{"sections":["experience","education","skills"]}', 'https://example.com/resumes/seeker6.pdf', true)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 13. Applications
-- --------------------------------------------------------------
INSERT INTO applications (id, job_id, seeker_id, resume_url, cover_letter, status, created_at)
VALUES
  ('a0000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'https://example.com/resumes/seeker1.pdf', 'Tôi có 3 năm kinh nghiệm Flutter và đam mê fintech. Hy vọng được đóng góp cho ABC.', 'pending',    now() - interval '3 days'),
  ('a0000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000001', 'https://example.com/resumes/seeker1.pdf', 'Mong muốn thử thách bản thân tại môi trường startup năng động.', 'reviewing',  now() - interval '5 days'),
  ('a0000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'https://example.com/resumes/seeker1.pdf', 'Kinh nghiệm mobile của tôi có thể chuyển đổi sang React Native nhanh chóng.', 'pending',    now() - interval '1 day'),
  ('a0000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', 'https://example.com/resumes/seeker2.pdf', 'Portfolio của tôi có 3 case study SaaS B2B phù hợp với vị trí này.', 'interview',  now() - interval '7 days'),
  ('a0000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000002', 'https://example.com/resumes/seeker2.pdf', 'Tôi có thể đóng góp về UI/UX trong team fullstack.', 'rejected',   now() - interval '4 days'),
  ('a0000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003', 'https://example.com/resumes/seeker3.pdf', '4 năm kinh nghiệm Node.js và microservices. Phù hợp hoàn hảo.', 'pending',    now() - interval '2 days'),
  ('a0000000-0000-0000-0000-000000000007', '50000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', 'https://example.com/resumes/seeker3.pdf', 'Tôi có thể cover cả backend và frontend cơ bản.', 'reviewing',  now() - interval '6 days'),
  ('a0000000-0000-0000-0000-000000000008', '50000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000003', 'https://example.com/resumes/seeker3.pdf', 'Kỹ năng Docker và infrastructure foundation tốt. Muốn chuyển hướng DevOps.', 'pending',    now() - interval '1 day'),
  ('a0000000-0000-0000-0000-000000000009', '50000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000004', 'https://example.com/resumes/seeker4.pdf', 'Profile data tại Đà Nẵng khớp vị trí Data Analyst tại Innovate Lab.', 'accepted',   now() - interval '10 days'),
  ('a0000000-0000-0000-0000-00000000000a', '50000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000004', 'https://example.com/resumes/seeker4.pdf', 'Tôi có nền tảng Python tốt, muốn học thêm DevOps.', 'pending',    now() - interval '2 days'),
  ('a0000000-0000-0000-0000-00000000000b', '50000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000005', 'https://example.com/resumes/seeker5.pdf', '5 năm PM + chứng chỉ PSM. Tìm cơ hội tại công ty product lớn.', 'interview',  now() - interval '5 days'),
  ('a0000000-0000-0000-0000-00000000000c', '50000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000005', 'https://example.com/resumes/seeker5.pdf', 'Tôi muốn tìm hiểu thêm về technical side qua vị trí này.', 'withdrawn',  now() - interval '8 days'),
  ('a0000000-0000-0000-0000-00000000000d', '50000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000006', 'https://example.com/resumes/seeker6.pdf', 'Tôi muốn chuyển hướng sang UI/UX content design.', 'pending',    now() - interval '3 days'),
  ('a0000000-0000-0000-0000-00000000000e', '50000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000006', 'https://example.com/resumes/seeker6.pdf', 'Kỹ năng content có thể hỗ trợ team React Native về copy và micro-copy.', 'pending',    now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 14. Bookmarks
-- --------------------------------------------------------------
INSERT INTO bookmarks (id, seeker_id, job_id, created_at)
VALUES
  ('b0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000006', now() - interval '2 days'),
  ('b0000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000005', now() - interval '1 day'),
  ('b0000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000001', now() - interval '3 days'),
  ('b0000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000003', now() - interval '5 days'),
  ('b0000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000007', now() - interval '1 day'),
  ('b0000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000009', now() - interval '2 days'),
  ('b0000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000001', now() - interval '4 days'),
  ('b0000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000002', now() - interval '3 days'),
  ('b0000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000004', now() - interval '6 days'),
  ('b0000000-0000-0000-0000-00000000000a', '30000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000006', now() - interval '2 days'),
  ('b0000000-0000-0000-0000-00000000000b', '30000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000007', now() - interval '1 day'),
  ('b0000000-0000-0000-0000-00000000000c', '30000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000008', now() - interval '3 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 15. Conversations & Messages
-- --------------------------------------------------------------
INSERT INTO conversations (id, seeker_id, recruiter_id, job_id, created_at)
VALUES
  ('c0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', now() - interval '2 days'),
  ('c0000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000004', now() - interval '5 days'),
  ('c0000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000005', now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;

INSERT INTO messages (id, conversation_id, sender_id, content, created_at, read_at)
VALUES
  ('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Chào chị Hoa, em đã nộp đơn Senior Flutter và rất quan tâm đến dự án fintech của công ty. Em có thể hỏi thêm về tech stack không ạ?', now() - interval '2 days', now() - interval '2 days'),
  ('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Chào em, team đang dùng Flutter 3.16 + Riverpod + Supabase backend. Em có kinh nghiệm với combo này chưa?', now() - interval '1 day', now() - interval '1 day'),
  ('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Dạ em đang dùng chính xác stack đó ở công ty hiện tại ạ. Em sẵn sàng phỏng vấn bất cứ lúc nào.', now() - interval '20 hours', null),
  ('d0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'Hi anh Nam, em đã nộp portfolio cho vị trí UI/UX Designer. Em muốn biết thêm về quy trình design tại XYZ.', now() - interval '5 days', now() - interval '5 days'),
  ('d0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'Hi Bình, team dùng Figma với design system Atomic. Em có thể qua văn phòng làm bài test 2h được không?', now() - interval '4 days', now() - interval '4 days'),
  ('d0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'Dạ được anh, em sẵn sàng. Anh cho em lịch tuần sau nhé.', now() - interval '3 days', now() - interval '3 days'),
  ('d0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'Chào anh, em nộp đơn Backend Node.js. Em có kinh nghiệm microservices với Docker và Kubernetes.', now() - interval '1 day', now() - interval '1 day'),
  ('d0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', 'Chào Cường, profile em rất khớp. Anh sẽ gửi link test HackerRank trong hôm nay.', now() - interval '10 hours', null)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 16. Notifications
-- --------------------------------------------------------------
INSERT INTO notifications (id, user_id, type, title, body, data_json, read, created_at)
VALUES
  ('e0000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'application_status', 'Đơn ứng tuyển đã được gửi', 'Bạn đã nộp đơn Senior Flutter Developer tại ABC Technology.', '{"job_id":"50000000-0000-0000-0000-000000000001"}'::jsonb, true,  now() - interval '3 days'),
  ('e0000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', 'message',            'Tin nhắn mới từ ABC Technology', 'Nguyễn Thị Hoa: "Chào em, team đang dùng Flutter 3.16..."', '{"conversation_id":"c0000000-0000-0000-0000-000000000001"}'::jsonb, false, now() - interval '1 day'),
  ('e0000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000002', 'interview',          'Bạn được mời phỏng vấn', 'XYZ Solutions mời bạn phỏng vấn vị trí UI/UX Designer.', '{"job_id":"50000000-0000-0000-0000-000000000004"}'::jsonb, false, now() - interval '4 days'),
  ('e0000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000002', 'message',            'Tin nhắn mới từ XYZ Solutions', 'Trần Văn Nam đã nhắn tin cho bạn.', '{"conversation_id":"c0000000-0000-0000-0000-000000000002"}'::jsonb, true,  now() - interval '4 days'),
  ('e0000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000003', 'application_status', 'Đơn ứng tuyển đang được xem xét', 'Đơn Backend Node.js Developer tại XYZ đang trong quá trình review.', '{"job_id":"50000000-0000-0000-0000-000000000005"}'::jsonb, true,  now() - interval '2 days'),
  ('e0000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000004', 'application_status', 'Đơn ứng tuyển được chấp nhận', 'Chúc mừng! Innovate Lab đã chấp nhận đơn Data Analyst của bạn.', '{"job_id":"50000000-0000-0000-0000-000000000007"}'::jsonb, false, now() - interval '10 days'),
  ('e0000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000001', 'new_applicant',      'Ứng viên mới nộp đơn', 'Nguyễn Văn An vừa nộp đơn Senior Flutter Developer.', '{"application_id":"a0000000-0000-0000-0000-000000000001"}'::jsonb, false, now() - interval '3 days'),
  ('e0000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000002', 'new_applicant',      'Ứng viên mới nộp đơn', 'Lê Văn Cường vừa nộp đơn Backend Node.js Developer.', '{"application_id":"a0000000-0000-0000-0000-000000000006"}'::jsonb, true,  now() - interval '2 days'),
  ('e0000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000001', 'new_applicant',      'Ứng viên mới nộp đơn', 'Hoàng Văn Em vừa nộp đơn Product Owner.', '{"application_id":"a0000000-0000-0000-0000-00000000000b"}'::jsonb, false, now() - interval '5 days'),
  ('e0000000-0000-0000-0000-00000000000a', '30000000-0000-0000-0000-000000000005', 'interview',          'Lịch phỏng vấn Product Owner', 'ABC Technology đề xuất phỏng vấn vào 10:00 AM ngày 15/06.', '{"job_id":"50000000-0000-0000-0000-000000000003"}'::jsonb, false, now() - interval '3 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 17. Company reviews
-- --------------------------------------------------------------
INSERT INTO company_reviews (id, company_id, reviewer_id, rating, content, created_at)
VALUES
  ('f0000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 5, 'Môi trường làm việc tuyệt vời, mentor rất tận tâm. Cơ sở vật chất hiện đại.', now() - interval '30 days'),
  ('f0000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000003', 4, 'Quy trình phỏng vấn chuyên nghiệp, feedback nhanh. Văn phòng đẹp.', now() - interval '20 days'),
  ('f0000000-0000-0000-0000-000000000003', '40000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000004', 5, 'Startup năng động, đội ngũ trẻ và sáng tạo. Cơ hội học hỏi rất nhiều.', now() - interval '15 days'),
  ('f0000000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000005', 3, 'Tuyển dụng hơi chậm, nhưng chất lượng công việc tốt. Cần cải thiện communication.', now() - interval '10 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 18. Saved searches
-- --------------------------------------------------------------
INSERT INTO saved_searches (id, user_id, filter_json, name, notify_new, created_at)
VALUES
  ('f1000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '{"keywords":"flutter","province":"Hồ Chí Minh"}'::jsonb, 'Flutter HCM', true, now() - interval '10 days'),
  ('f1000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', '{"keywords":"ui ux","province":"Hà Nội"}'::jsonb,        'UI/UX Hà Nội', true, now() - interval '7 days'),
  ('f1000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', '{"keywords":"backend nodejs","type":"remote"}'::jsonb,  'Backend Remote', false, now() - interval '5 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 19. AI suggestions (pre-cached with Vietnamese reasons)
-- --------------------------------------------------------------
INSERT INTO ai_suggestions (id, seeker_id, job_id, score, reason, cached_at)
VALUES
  -- seeker1 (Flutter dev)
  ('a1000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 0.95, 'Bạn có 3 năm kinh nghiệm Flutter và Dart nâng cao. Công ty ABC đang tìm Senior Flutter Developer tại Hồ Chí Minh — khớp hoàn hảo cả kỹ năng lẫn địa điểm.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000008', 0.88, 'Kỹ năng Flutter, Firebase và REST API của bạn vượt trội so với yêu cầu vị trí Junior. Đây là cơ hội để bạn dẫn dắt team nhỏ tại startup.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000002', 0.72, 'Bạn có nền tảng mobile tốt (Flutter). React Native là công nghệ liên quan, bạn có thể chuyển đổi nhanh chóng với kinh nghiệm JavaScript.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000003', 0.45, 'Vị trí Product Owner cần nhiều kỹ năng business và quản lý. Hồ sơ của bạn hướng về kỹ thuật, chưa thể hiện rõ kinh nghiệm product management.', now() - interval '1 day'),
  -- seeker2 (UI/UX)
  ('a1000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000004', 0.94, 'Hồ sơ của bạn thể hiện chuyên môn cao về Figma và UI/UX Design. XYZ Solutions đang tìm designer cho sản phẩm SaaS — rất phù hợp với kinh nghiệm của bạn.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000006', 0.38, 'Vị trí Fullstack tập trung vào lập trình React + Node.js, trong khi hồ sơ của bạn hướng về thiết kế. Bạn có thể cần bổ sung kỹ năng lập trình nếu muốn ứng tuyển.', now() - interval '1 day'),
  -- seeker3 (Backend)
  ('a1000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000005', 0.96, 'Kỹ năng Node.js, PostgreSQL, Docker và Git của bạn khớp hoàn hảo với yêu cầu. Kinh nghiệm 4 năm backend là lợi thế lớn so với các ứng viên khác.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000006', 0.78, 'Backend mạnh nhưng frontend (React) chưa xuất hiện trong hồ sơ. Có thể cần bổ sung kỹ năng này hoặc phối hợp chặt với frontend dev trong team.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000003', '50000000-0000-0000-0000-000000000009', 0.70, 'Docker và SQL có trong hồ sơ, nhưng thiếu kỹ năng cloud infrastructure (AWS/GCP/K8s) chuyên sâu. Cần bổ sung nếu muốn chuyển hướng DevOps.', now() - interval '1 day'),
  -- seeker4 (Data)
  ('a1000000-0000-0000-0000-00000000000a', '30000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000007', 0.92, 'Python, SQL, Data Analysis và Power BI — tất cả đều khớp yêu cầu. Vị trí tại Đà Nẵng phù hợp địa điểm của bạn, giảm thiểu thời gian di chuyển.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-00000000000b', '30000000-0000-0000-0000-000000000004', '50000000-0000-0000-0000-000000000009', 0.40, 'Thiếu nhiều kỹ năng infrastructure và CI/CD. Không phải hướng đi phù hợp với profile data analysis của bạn.', now() - interval '1 day'),
  -- seeker5 (PM)
  ('a1000000-0000-0000-0000-00000000000c', '30000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000003', 0.89, '5 năm kinh nghiệm Product Management và chứng chỉ PSM I là điểm cộng lớn. Vị trí tại Hồ Chí Minh khớp địa điểm và quy mô công ty bạn mong muốn.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-00000000000d', '30000000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000001', 0.30, 'Vị trí kỹ thuật cao (Senior Flutter) không liên quan đến kỹ năng quản lý sản phẩm của bạn. Cần chuyển hướng rõ ràng hơn nếu muốn đổi ngành.', now() - interval '1 day'),
  -- seeker6 (Marketing)
  ('a1000000-0000-0000-0000-00000000000e', '30000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000004', 0.42, 'Thiếu kỹ năng thiết kế chuyên sâu. Hồ sơ của bạn hướng về marketing content, không phải UI/UX design.', now() - interval '1 day'),
  ('a1000000-0000-0000-0000-00000000000f', '30000000-0000-0000-0000-000000000006', '50000000-0000-0000-0000-000000000002', 0.25, 'Không có kỹ năng lập trình mobile trong hồ sơ. Vị trí này yêu cầu kinh nghiệm React Native và TypeScript.', now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 20. Profile & Job embeddings (random 768-dim vectors)
-- --------------------------------------------------------------
INSERT INTO profile_embeddings (user_id, embedding, updated_at)
VALUES
  ('30000000-0000-0000-0000-000000000001', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('30000000-0000-0000-0000-000000000002', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('30000000-0000-0000-0000-000000000003', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('30000000-0000-0000-0000-000000000004', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('30000000-0000-0000-0000-000000000005', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('30000000-0000-0000-0000-000000000006', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now())
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO job_embeddings (job_id, embedding, updated_at)
VALUES
  ('50000000-0000-0000-0000-000000000001', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000002', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000003', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000004', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000005', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000006', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000007', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000008', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now()),
  ('50000000-0000-0000-0000-000000000009', (SELECT array_agg(random()::real)::vector(768) FROM generate_series(1, 768)), now())
ON CONFLICT (job_id) DO NOTHING;

-- --------------------------------------------------------------
-- 21. Interview schedules
-- --------------------------------------------------------------
INSERT INTO interview_schedules (id, application_id, scheduled_at, location, note, status)
VALUES
  ('a2000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000004', now() + interval '5 days',  'XYZ Solutions Office, Tầng 5, 12 Phố Duy Tân, Cầu Giấy, Hà Nội', 'Mang laptop + portfolio Figma.', 'scheduled'),
  ('a2000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-00000000000b', now() + interval '7 days',  'ABC Technology Tower, Tầng 15, 123 Nguyễn Huệ, Quận 1, HCM', 'Phỏng vấn 2 vòng: HR + Product Director.', 'scheduled'),
  ('a2000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', now() + interval '3 days',  'Google Meet — link sẽ gửi trước 30 phút', 'Phỏng vấn technical: Live coding Flutter + system design.', 'scheduled')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 22. Application notes
-- --------------------------------------------------------------
INSERT INTO application_notes (id, application_id, recruiter_id, note, created_at)
VALUES
  ('a3000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Kinh nghiệm Flutter tốt, có dẫn dắt team. Đề xuất phỏng vấn technical.', now() - interval '2 days'),
  ('a3000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000002', 'Technical screening passed. Kỹ năng SQL và Docker vững. Đề xuất interview vòng 2.', now() - interval '1 day'),
  ('a3000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-00000000000b', '20000000-0000-0000-0000-000000000001', 'Profile PM mạnh nhưng cần test case study để đánh giá tư duy product.', now() - interval '3 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- 23. Reports
-- --------------------------------------------------------------
INSERT INTO reports (id, reporter_id, target_type, target_id, target_snapshot, reason, status, created_at)
VALUES
  ('a4000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'job_post', '50000000-0000-0000-0000-000000000002', '{"title":"React Native Developer"}'::jsonb, 'Tin đăng nghi ngờ spam — mô tả quá ngắn và không rõ ràng.', 'pending', now() - interval '1 day'),
  ('a4000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000003', 'job_post', '50000000-0000-0000-0000-000000000009', '{"title":"DevOps Engineer"}'::jsonb, 'Mức lương quá thấp so với thị trường, có dấu hiệu câu view.', 'pending', now() - interval '2 days')
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------------------------
-- Done
-- --------------------------------------------------------------
