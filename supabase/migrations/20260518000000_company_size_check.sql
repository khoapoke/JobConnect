-- T-13: Company size CHECK constraint
ALTER TABLE companies
  ADD CONSTRAINT companies_size_check
  CHECK (size IS NULL OR size IN (
    '1-10', '11-50', '51-200',
    '201-500', '501-1000', '1000+'
  ));
