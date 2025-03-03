# class TenantService
#   def self.switch(company)
#     if company && company.database.present?
#       ActiveRecord::Base.establish_connection(
#         Rails.configuration.database_configuration[Rails.env]["dynamic_tenant"].merge("database" => company.database)
#       )
#     else
#       raise "Company database not found!"
#     end
#   end
# end
class TenantService
  def self.switch(company)
    return unless company&.database.present?
    ActiveRecord::Base.establish_connection(
      adapter: "mysql2",
      database: company.database,
      username: "root",
      password: "Password123",
      host: "localhost",
      port: 3306
    )
  end
end
