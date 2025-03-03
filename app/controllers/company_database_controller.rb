class CompanyDatabaseController < ApplicationController
  def find_comp
    return render json: {data: "workoing"}, status: 200
  end

end
