class TenantMiddleware

  def initialize(app)

    @app = app

  end

  def call(env)
    request = Rack::Request.new(env)
    subdomain = request.host.split(".").first  # Example: company1.staging.devrising.in
    company = CompanyLogin.find_by(name: subdomain) # Find company by subdomain
    TenantService.switch(company) if company

    @app.call(env)
  end
end
