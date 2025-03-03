class CompanyLogin < PrimaryRecord
  self.abstract_class = true
  # connects_to database: { writing: :primary, reading: :primary }

  self.table_name = "company_logins" # Ensure this matches your actual table name
  connects_to database: { writing: :primary, reading: :primary }
end
