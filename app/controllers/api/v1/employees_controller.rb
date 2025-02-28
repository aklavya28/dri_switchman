class Api::V1::EmployeesController < ApplicationController
  # require 'json'
  # require 'pagy/extras/jsonapi'
  # before_action :account_params, only: [:create]
  before_action :authenticate_user!
  # before_action :permit_vender, only: [:create_ledger]

  def index
    render json:{ status: "Successfully", data: Employee.where(company_id: current_user.company_id).order(id: :desc)  }, status: 200 and return
  end
  def get_active_employees
    render json:{ status: "Successfully", data: Employee.where(company_id: current_user.company_id, is_active: true).select("id,full_name, fathername, mobile, slug").order(id: :desc)  }, status: 200 and return
  end


  def show
   @emp = Employee.find_by_slug(params[:id])
   if  @emp.present?
    render json:{ status: "Successfully", data:@emp  }, status: 200 and return
    else
      render json: { error: "Not data found" }, status: 401 and return
   end
    # return render json: data
  end
  def nominee_relation
    if NOMINEE_RELATION.present?
      render json:{ status: "Ledger Registered Successfully", data: NOMINEE_RELATION  }, status: 200 and return
      else
        render json: { error: "Duplicate ledger name" }, status: 401 and return
    end
  end
  def create

    if Employee.find_by(mobile:params[:employee][:mobile] ).present?
      render json: { error: "Duplicate Mobile Number"  }, status: 401 and return
    end
    if Employee.find_by(email: params[:employee][:email] ).present? && params[:employee][:email].present?
      render json: { error: "Duplicate email"  }, status: 401 and return
    end

    @employee = Employee.new( params.fetch(:employee, {}).permit!)
    @employee.is_active = true
    @employee.company_id = current_user.company_id
    @employee.user_id = current_user.id
    @employee.save!
    if @employee.present?
      render json:{ status: "Employee Registered Successfully", data: @employee  }, status: 200 and return
    else
      render json: { error: "Somthing want worng!" }, status: 401 and return
    end
  end
  # Api::V1::EmployeesController.allowance_deduction_list
  def allowance_deduction_list
     data = ALLOWANCE_DEDUCTION.reject{|t| t[:id] == 10}
    return render json: data
  end
  def create_salary
     @emp =  Employee.find_by(slug: params[:slug])



     if @emp.present?

      @add_eployer_pf = []

      params[:item_data][:item_data].each do |d|
        if d["allowance_id"] == "8,deduction,PF"
          @add_eployer_pf << d
          @add_eployer_pf << {:allowance_id =>  "10,allowance,Employer PF Share", :amount => d["amount"]}
        else
          @add_eployer_pf << d
        end
      end
      ndata = params[:salary_data].to_unsafe_h
      ndata["item_data"] =  @add_eployer_pf

      @emp.update(salary_settings: ndata)
      # @emp.update(salary_settings: {:item_data => @add_eployer_pf})

        if(@emp)
          render json:{ status: "Wages created successfully", data: @emp  }, status: 200 and return
          else
            render json: { error: "Somthing want worng!" }, status: 401 and return
        end
      else
        render json: { error: "No Employee found" }, status: 401 and return
     end

    return render json:[ @emp, params[:salary_data]]
  end

  def change_active_status_employee
    @emp =  Employee.find_by(slug: params[:slug])
    if( @emp.present?)
      @emp.update(is_active: params[:is_active])
      if(@emp)
        render json:{ status: "Status chaned successfully", data: @emp  }, status: 200 and return
        else
          render json: { error: "Somthing want worng!" }, status: 401 and return
      end
      else
        render json: { error: "No Employee found" }, status: 401 and return
    end

  end
  # Api::V1::EmployeesController.test
  def self.test
    @emp =  Employee.where(is_active: true, company_id:1)
    .where.not(salary_settings: nil)
    .includes(:advance_salary_payouts)
    .select("amount as #{:advance_salary_payouts.first}")




    # Employee.where(is_active: true, company_id:1)
    # .where.not(salary_settings: nil).collect{ |d| d.advance_salary_payouts.where(is_paid: false).first}

  end

  def employees_salary_disbursement
    # @emp = Employee.where(is_active: true, company_id: current_user.company_id).where.not(salary_settings: nil).order(id: :desc)
    @emp =   Employee.includes(:advance_salary_payouts)
    .where(is_active: true, company_id: current_user.company_id).where.not(salary_settings: nil).order(id: :desc)

    if(@emp.present?)
      render json:{ status: "Success", data: @emp  }, status: 200 and return
    else
      render json: { error: "No Employee found" }, status: 401 and return
    end
  end
  def get_liquid
      @acc=[]
      Plutus::Account.where(is_liquid: true, company_id: current_user.company_id).each do |ac|
        d = ac.name.split("_")
        name = d.take(d.count - 1).join(" ")
        balance = Plutus::Account.find_by_name(ac.name).balance.to_f.round(2)
        @acc << {:id=> ac.id, :name => name, orginal_name: ac.name,is_bank: ac.is_bank, :balance =>balance }
      end
      if(@acc.present?)
        render json:{ status: "Success", data: @acc  }, status: 200 and return
      else
        render json: { error: "No account found" }, status: 401 and return
      end
  end
  def create_advance_salary
      amt = params[:data][:amount].to_f
      bal = Plutus::Account.find_by_id(params[:data][:payment_ledger_id]).balance.to_f

    unless amt < bal
      render json: { error: "Unable to process advance salary payment of Rs. #{amt}. Available ledger balance is Rs. #{bal}. " }, status: 401 and return
    end

    @adv_salary =  AdvanceSalary.new( params.fetch(:data, {}).except(:employee_id_main).permit!)
    @adv_salary.company_id = current_user.company_id
    @adv_salary.user_id = current_user.id
    @adv_salary.save!
    # @adv_salary = AdvanceSalary.first
    if(@adv_salary.present?)
      # plutus
        advance_salary_plutus(@adv_salary)
        @adv_salary.update(is_processed: true)
      # plutus
      payount_amount = (@adv_salary.amount.to_f.round(2)/ @adv_salary.tenure)
      @payoutdata = []

     (0... @adv_salary.tenure).each do |t|
        @new_payout =  @adv_salary.advance_salary_payouts.new
        @new_payout.amount =  payount_amount
        @new_payout.emp_id =  @adv_salary.employee_id
         @new_payout.company_id =  current_user.company_id
        @new_payout.save!
        @payoutdata << @new_payout
     end
      if( @payoutdata.present?)
      render json:{ status: "Success", data: @adv_salary, entries: @payoutdata }, status: 200 and return
      else
        render json: { error: "Not saveed" }, status: 401 and return
      end
    else
      render json: { error: "Not saveed" }, status: 401 and return
    end
  end
  def advance_salary_plutus(adv_salary)
    @credit_ac = Plutus::Account.find_by_id(adv_salary.payment_ledger_id)
    @debit_ac = Plutus::Account.find_by_name("advance_salary_#{current_user.company_id}")
    @p_entry = Plutus::Entry.new(
      :description => "Advance Salary for employee empID: #{adv_salary.employee_id}, sum of Rs. #{adv_salary.amount} ",
      :date => adv_salary.created_at,
      :commercial_document_type => AdvanceSalary,
      :commercial_document_id => adv_salary.id,
      :company_id => current_user.company_id,
      :debits => [
        {:account_name => @debit_ac.name,:amount => adv_salary.amount, :company_id => current_user.company_id },
      ],
      :credits => [
      {:account_name => @credit_ac.name, :amount => adv_salary.amount, :company_id => current_user.company_id}
    ])
    @p_entry.save!
  end
#   def promoter_params
#     params.fetch(:promoter, {}).permit!
#   end

#  def permit_vender
#     params[:vender].fetch(:vender_detail, {}).permit!
#  end
end
