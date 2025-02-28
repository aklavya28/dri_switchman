module Accounting::Khatabook
  # Accounting::Khatabook.approve_khata_transaction
  def self.approve_khata_transaction(id)
    trn = KhataTransaction.find_by_id(id)
    if trn.payment_type.downcase == "paid"
      paid_transaction(trn)
    elsif trn.payment_type.downcase == "received"
      received_transaction(trn)
    end
  end

  def self.paid_transaction(trn)
    company_id = trn.company_id
    khata = Khatabook.find_by_id(trn.khatabook_id)
    debit = []
    credit = []
     debit <<  {:account_name => "#{khata.ledger_name}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }
      trn.paid_to.each do |cr|
        l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
      end
        # debit <<  {:account_name => "#{liability_ac}_#{company_id}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }

        # trn.paid_to.each do |cr|
        #     l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
        #     amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        #     credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
        # end
          # erntry part
          @entry = Plutus::Entry.new(
            :description => "Amount paid to khata #{khata.name}, a/c #{khata.ledger_name}",
            :date => trn.transaction_date,
            :commercial_document_type => KhataTransaction,
            :commercial_document_id => trn.id,
            :company_id => company_id,
            :debits => debit,
            :credits => credit
          )
          @entry.save!
          if(@entry.present?)
            trn.update(is_processed: true)
          end
          # erntry part


  end


  def self.received_transaction(trn)
    company_id = trn.company_id
    khata = Khatabook.find_by_id(trn.khatabook_id)
    debit = []
    credit = []
    # if khata.khata_type.downcase == 'creditor'
      trn.paid_to.each do |cr|
        l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        debit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
      end
      credit <<  {:account_name => "#{khata.ledger_name}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }
    # elsif khata.khata_type.downcase == 'debtor'
      # debit <<  {:account_name => "#{khata.ledger_name}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }
      # trn.paid_to.each do |cr|
      #   l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
      #   amount = BigDecimal(cr["value"].to_f.round(2).to_s)
      #   credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
      # end
    # end

      # erntry part
      @entry = Plutus::Entry.new(
        :description => "Amount received From khata #{khata.name}, #{khata.ledger_name}",
        :date => trn.transaction_date,
        :commercial_document_type => KhataTransaction,
        :commercial_document_id => trn.id,
        :company_id => company_id,
        :debits => debit,
        :credits => credit
      )
      @entry.save!
      if(@entry.present?)
        trn.update(is_processed: true)
      end
      # erntry part
  end

  def self.paid_advance_transaction(trn)
    company_id = trn.company_id
    khata = Khatabook.find_by_id(trn.khatabook_id)
    asset_ac = "#{khata.dr_number.downcase}"
    debit = []
    credit = []

    debit <<  {:account_name => "#{asset_ac}_#{company_id}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }
    trn.paid_to.each do |cr|
      l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
      amount = BigDecimal(cr["value"].to_f.round(2).to_s)
      credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
    end
puts ["dddd",debit,credit]
      # erntry part
      @entry = Plutus::Entry.new(
        :description => "Amount received against khata #{khata.name}, #{asset_ac.upcase}",
        :date => trn.transaction_date,
        :commercial_document_type => KhataTransaction,
        :commercial_document_id => trn.id,
        :company_id => company_id,
        :debits => debit,
        :credits => credit
      )
      @entry.save!
      if(@entry.present?)
        trn.update(is_processed: true)
      end
      # erntry part



  end

  def self.received_advance_transaction(trn)
    company_id = trn.company_id
    khata = Khatabook.find_by_id(trn.khatabook_id)
    liability_ac = "#{khata.cr_number.downcase}"
    debit = []
    credit = []

    trn.paid_to.each do |cr|
      l_name = "#{cr["title"].downcase.split(" ").join("_")}_#{company_id}"
      amount = BigDecimal(cr["value"].to_f.round(2).to_s)
      debit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
    end
    credit <<  {:account_name => "#{liability_ac}_#{company_id}",:amount => BigDecimal(trn.amount.to_f.round(2).to_s), :company_id => company_id }

      # erntry part
      @entry = Plutus::Entry.new(
        :description => "Amount received against khata #{khata.name}, #{liability_ac.upcase}",
        :date => trn.transaction_date,
        :commercial_document_type => KhataTransaction,
        :commercial_document_id => trn.id,
        :company_id => company_id,
        :debits => debit,
        :credits => credit
      )
      @entry.save!
      if(@entry.present?)
        trn.update(is_processed: true)
      end
      # erntry part



  end



end
