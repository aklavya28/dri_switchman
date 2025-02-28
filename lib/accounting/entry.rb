module Accounting::Entry
  #  Accounting::Entry.process_entry_promoter( trns_modal = "Promoter")


  def self.process_entry_promoter( trns_modal = "Promoter")

    Company.all.each do |cid|
      company_id = cid.id

      # dr_ac_cash = Plutus::Account.where(company_id: company_id, name:"cash_book_#{company_id}").first;
      # dr_ac_bank = Plutus::Account.where(company_id: company_id, name:"bank_book_#{company_id}").first;
      # return puts dr_ac_bank

      cr_ac = Plutus::Account.where(company_id: company_id, name:"promoters_#{company_id}").first;
      (trns_modal).constantize.where(payment_status: "success", is_processed: true, company_id: company_id).find_each do |t|
        # t.payment_mode == 'cash'? dr_ac = dr_ac_cash : dr_ac = dr_ac_bank
        puts t.inspect
        dr_ac = Plutus::Account.find_by_id(t.payment_ledger_id);

        @entry = Plutus::Entry.new(
            :description => "Order placed for share",
            :date => t.allotment_date,
            :commercial_document_type => trns_modal,
            :commercial_document_id => t.id,
            :company_id => company_id,
        :debits => [
             {:account_name => dr_ac.name, :amount =>  BigDecimal(t.amount), :company_id => company_id}],
        :credits => [
            {:account_name => cr_ac.name, :amount => BigDecimal(t.amount), :company_id => company_id}])
            @entry.save!
          if(@entry.present?)
            t.update(is_processed: true)
            # puts "************ mera pahala plutus code ********************"
          end

      end
    end


  end

  def self.delete_promoter_process
    Promoter.where(payment_status: "success",  company_id: 1).find_each do |t|
      t.update(is_processed: false)
    end
  end
  # Accounting::Entry.process_expense_entry
  def self.process_expense_entry(exp)
    company_id = exp.company_id
    cat_name = ExpenseCategory.find_by_id(exp.expense_category_id).name
    amount = exp.amount
    transaction_date = exp.transaction_date
    payment_ledger_name = Plutus::Account.find_by_id(exp.payment_ledger_id).name
    actual_name = payment_ledger_name.gsub("_#{company_id}", '').split("_").join(" ")
    debit = [ {:account_name => "company_expenses_#{company_id}",:amount => amount, :company_id => company_id }]
    # debit side end

    # credit side
    credit = [{:account_name => payment_ledger_name, :amount => amount, :company_id => company_id }]
    @entry = Plutus::Entry.new(
      :description => "Paid Rs.#{amount} for #{cat_name.upcase} via #{actual_name.upcase} transfer",
      :date => transaction_date,
      :commercial_document_type => ExpenseEntry,
      :commercial_document_id => exp.id,
      :company_id => company_id,
      :debits => debit,
      :credits => credit
    )

    @entry.save!
    if(@entry.present?)
      exp.update(is_processed: true)
      # puts "************ mera pahala plutus code ********************"
    end



  end

  # Accounting::Entry.process_reverse_expense_entry
  def self.process_reverse_expense_entry(exp)
    company_id = exp.company_id
    cat_name = ExpenseCategory.find_by_id(exp.expense_category_id).name
    amount = exp.amount
    transaction_date = exp.transaction_date
    payment_ledger_name = Plutus::Account.find_by_id(exp.payment_ledger_id).name
    actual_name = payment_ledger_name.gsub("_#{company_id}", '').split("_").join(" ")
    credit = [ {:account_name => "company_expenses_#{company_id}",:amount => amount, :company_id => company_id }]
    # debit side end

    # credit side
    debit = [{:account_name => payment_ledger_name, :amount => amount, :company_id => company_id }]
    @entry = Plutus::Entry.new(
      :description => "Paid Rs.#{amount} for #{cat_name.upcase} via #{actual_name.upcase} transfer reversed",
      :date => transaction_date,
      :commercial_document_type => ExpenseEntry,
      :commercial_document_id => exp.id,
      :company_id => company_id,
      :debits => debit,
      :credits => credit
    )

    @entry.save!
    if(@entry.present?)
      exp.update(is_processed: true)
      # puts "************ mera pahala plutus code ********************"
    end



  end


end
