module Accounting::Share

  def self.promoter_share(entry)
      company_id = entry.company_id
      cr_ac = Plutus::Account.where(company_id: company_id, name:"promoters_#{company_id}").first;
      dr_ac = Plutus::Account.find_by_id(entry.payment_ledger_id);
      user = User.find_by_id(entry.user_id)
      fullname = "#{user.f_name} #{user.l_name}"

        @entry = Plutus::Entry.new(
            :description => " An order for #{entry.total_shares} units has been placed by #{fullname}",
            :date => entry.allotment_date,
            :commercial_document_type => Promoter,
            :commercial_document_id => entry.id,
            :company_id => company_id,
        :debits => [
             {:account_name => dr_ac.name, :amount =>  BigDecimal(entry.amount.to_f.round(2).to_s), :company_id => company_id}],
        :credits => [
            {:account_name => cr_ac.name, :amount => BigDecimal(entry.amount.to_f.round(2).to_s), :company_id => company_id}])
            @entry.save!
          if(@entry.present?)
            entry.update(is_processed: true)
            # puts "************ mera pahala plutus code ********************"
          end
  end
end
