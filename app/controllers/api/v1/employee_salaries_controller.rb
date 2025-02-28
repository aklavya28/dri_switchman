class Api::V1::EmployeeSalariesController < ApplicationController
  require 'json'
  # require 'pagy/extras/jsonapi'
  # before_action :account_params, only: [:create]
  before_action :authenticate_user!
  # before_action :permit_vender, only: [:create_ledger]
  def create
    # return render json:  params[:order_data][:installment_ids].to_json
    #
    # cr_ledger_id
    # gross_salaries
   ledger_bal =  Plutus::Account.find_by_id(params[:order_data][:cr_ledger_id]).balance.to_f
   gross_salaries = params[:order_data][:gross_salaries].to_f
   if gross_salaries > ledger_bal
      render json: { error: "Cannot pay morthen available balance Rs. #{ledger_bal} " }, status: 401 and return
   end
    installment_breckup = []
    params["entry_data"].each do |ins|
      if (ins["installment"] > 0)
        installment_breckup << {:imp_slug => ins["slug"], :installment => ins["installment"]}
      end
    end
    # return render json: params
    @sal = EmployeeSalary.new( params.fetch(:order_data, {}).permit!)
    @sal.payment_type ="debit"
    @sal.installment_ids = params[:order_data][:installment_ids].to_json
    @sal.installment_breckup = installment_breckup
    @sal.company_id = current_user.company_id
    @sal.user_id = current_user.id

    if @sal.save!

      # update advance payout for installment
       update_advance_payout_true(@sal.id)
      # return render json:  [@sal, params]
      @data = []
      params[:entry_data].each_with_index do |t,v|
        @trans =  @sal.employee_salary_transactions.new(  params[:entry_data].fetch(v, {}).except(:checked,:installment_id).permit!)
        @trans.company_id = current_user.company_id
        @trans.user_id = current_user.id
        @trans.employee_id = Employee.find_by(slug: t[:slug]).id
        @trans.save!
        @data << @trans
      end
      if(@data.present?)
        @new_updated_col = update_salary_order( @data)
        @sal.update(allowances_breack_up: @new_updated_col[:allowance_data], deductions_breack_up: @new_updated_col[:deduction_data] )
        @p_entry = employee_salaries_plutus(current_user.company_id,@sal)
        if  @p_entry.present?
          render json:{ status: "Successfully", data:@p_entry  }, status: 200 and return
        else
        render json: { error: "Not data found" }, status: 401 and return
        end
      end
    end


  end

  def get_disbursement_history
    @salary = EmployeeSalary.where(company_id: current_user.company_id).order(salary_date: :desc).limit(100)

    if (@salary.present?)
      render json:{ status: "Order Placed Successfully", data: @salary }, status: 200 and return
    else
      render json: { error: "Somthing want wrong" }, status: 401 and return
    end
  end
def get_advance_salary_payouts
    @emp = Employee.find_by_slug( params[:slug]).id
    @base =  AdvanceSalaryPayout.where(emp_id: @emp, is_paid: false)
    @payuts =  AdvanceSalaryPayout.where(emp_id: @emp)
    render json:{ status: "Order Placed Successfully",payout: @payuts, current_installment_amt:@base.first , sum: @base.sum(:amount).ceil }, status: 200 and return
    # return render json:
end



  def get_disbursement_history_details
    @salaries =  EmployeeSalary.find_by(slug: params[:slug]).employee_salary_transactions
    @data = @salaries.select("employee_salary_transactions.*").joins(:employee).select("employees.full_name, employees.slug as emp_slug, employees.designation")
    if(@data.present?)
      render json:{ status: "Order Placed Successfully", data: @data }, status: 200 and return
    else
      render json: { error: "Somthing want wrong" }, status: 401 and return
    end
  end


   # Api::V1::EmployeeSalariesController.update_salary_order
  def update_salary_order(data)
    # def self.update_salary_order

    # update maain order form salries
    #  data =  EmployeeSalary.find_by(id:8).employee_salary_transactions

     if(data.present?)
    allowance= []
    deduction = []
      ALLOWANCE_DEDUCTION.each do |e|
          if e[:type] == 'allowance'
              allowance << e[:name]
            else
              deduction << e[:name]
          end
      end
      unqi_keys_hash = {:allowance => allowance, :deduction => deduction}
      # next
      # allowance_data = {}
      # data_a = {}
      allowance_data =  get_brack_up(data, unqi_keys_hash, "allowance" )
      deduction_data =  get_brack_up(data, unqi_keys_hash, "deduction" )
      return {:allowance_data => allowance_data, :deduction_data => deduction_data}
      # return puts [allowance_data, deduction_data]
    end
  end
  # def self.get_brack_up(data, unqi_keys_hash, type )
  def get_brack_up(data, unqi_keys_hash, type )
    data_d = {}
    unqi_keys_hash[type.to_sym].each do |d_key|
      @key  = d_key.split(" ").join("_").downcase.to_sym
        @amount = 0
           data.each do|e|
            e.break_up["item_data"].each do |i|
              if(d_key == i["allowance_id"].split(",").last)
                 puts ["dfsdf", i["allowance_id"]]

                @amount += i["amount"].to_f
                 # key = i["allowance_id"].split(",").last.split(" ").join("_").downcase
              end

            end
          end
         @amount > 0 ? data_d.store(@key, @amount): '';
      end
      return data_d
  end

  # Api::V1::EmployeeSalariesController.employee_salaries_plutus(cmp_id =1)
  def employee_salaries_plutus(cmp_id,data)
    # @d_salary = EmployeeSalary.first()
    @d_salary = data
    message = "Bulk salary disbursement to employees on date: #{@d_salary.salary_date.to_date} Gross Salary: #{@d_salary.gross_salaries} and Net Salary: #{@d_salary.net_salaries}"
    # debit
    debit_logic=[]
    credit_logic=[]
    credit_amt =0.0
    debit_1 = Plutus::Account.find_by_name("salary_#{cmp_id}")
    # if @d_salary.installment.present? && @d_salary.installment.to_f > 0
    #   debit_logic << {:account_name => debit_1.name,:amount => (@d_salary.net_salaries.to_f.round(2) + @d_salary.installment.to_f), :company_id =>cmp_id}
    # else
      debit_logic << {:account_name => debit_1.name,:amount => @d_salary.gross_salaries.to_f.round(2), :company_id =>cmp_id}
    # end


    # credit logic


    if @d_salary.deductions_breack_up.present?
          @d_salary.deductions_breack_up.each do |k, v|
            if(k == 'pf')
              ac =  Plutus::Account.find_by_name("#{k}_#{cmp_id}").name
              ac2 =  Plutus::Account.find_by_name("employer_#{k}_#{cmp_id}").name
              credit_logic << {:account_name => ac2, :amount => v.to_f.round(2), :company_id =>cmp_id}
              credit_logic << {:account_name => ac, :amount => v.to_f.round(2), :company_id =>cmp_id}
              credit_amt += v.to_f.round(2)*2
            else
              ac =  Plutus::Account.find_by_name("#{k}_#{cmp_id}").name
              credit_logic << {:account_name => ac, :amount => v.to_f.round(2), :company_id =>cmp_id}
              credit_amt += v.to_f.round(2)
            end
          end
    end
    credit_1 = Plutus::Account.find_by_id(@d_salary.cr_ledger_id).name
    credit_3 = Plutus::Account.find_by_name("advance_salary_#{cmp_id}").name

    credit_logic << {:account_name => credit_1,:amount => @d_salary.net_salaries.to_f.round(2), :company_id =>cmp_id}
    # if @d_salary.deductions_breack_up.present?
    #   credit_logic << {:account_name => credit_2,:amount => debit_amt, :company_id =>cmp_id}
    # end
    if @d_salary.installment.present? && @d_salary.installment.to_f > 0
      credit_logic << {:account_name => credit_3,:amount => @d_salary.installment.to_f, :company_id =>cmp_id}
    end


    #credit

    # return puts @d_salary.deductions_breack_up.with_indifferent_access

    # return puts [debit_logic,"*****", credit_logic]
    @p_entry = Plutus::Entry.new(
      :description => message,
      :date => @d_salary.salary_date,
      :commercial_document_type => EmployeeSalary,
      :commercial_document_id => @d_salary.id,
      :company_id => cmp_id,
      :debits => debit_logic,
      :credits => credit_logic
    )
    @p_entry.save!
    @d_salary.update(is_processed: true)
  end

  # Api::V1::EmployeeSalariesController.test(4)
  def update_advance_payout_true(order)
   @ids = JSON.parse(EmployeeSalary.find(order).installment_ids)
   if @ids.count > 0
     AdvanceSalaryPayout.where(id: @ids).update_all(is_paid: true)
   end
  end



end
