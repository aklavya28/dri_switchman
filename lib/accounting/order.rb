module Accounting::Order
  # Accounting::Order.approve_order
  def self.approve_order(order_id)
    order = Order.find_by_id(order_id)
    if order.order_type.downcase =='debit' && !order.is_returned
      store_debit_order(order)
    elsif order.order_type.downcase =='credit' && !order.is_returned
        store_credit_order(order)
    elsif order.order_type.downcase =='debit' && order.is_returned
      sale_return_order(order)
    elsif order.order_type.downcase =='credit' && order.is_returned
      purchase_return_order(order)
    end
    # puts order.order_type.downcase =='debit'
  end
  # Accounting::Order.store_debit_order
  def self.store_debit_order(order)
  #  def self.store_debit_order
  #     order = Order.find_by_id(45)
      company_id = order.company_id
      paid_from = order.paid_from


      # debit side
      service = BigDecimal(order.sale_service_transactions.sum(:amount).to_f.round(2).to_s)
      gst = BigDecimal(order.gst_paid.to_f.round(2).to_s)
      assets_sum = order.fixed_assets.sum{|f| f.no_of_unit * f.unit_amount}.to_f.round(2)
      assets = BigDecimal(assets_sum.to_s)
      test_store =( order.grand_total - (service + gst + assets))
      store = BigDecimal(test_store.to_f.round(2).to_s)
      round_off_amount = BigDecimal(order.round_off_amount.to_f.round(2).to_s)
      # debit ==========================
      debit = [ ]
      debit <<  {:account_name => "gst_paid_#{company_id}",:amount => gst, :company_id => company_id } if gst > 0
      debit << {:account_name => "service_expense_#{company_id}",:amount => service, :company_id => company_id } if service > 0
      debit << {:account_name => "fixed_assets_#{company_id}",:amount => assets, :company_id => company_id } if assets > 0
      if round_off_amount > 0
        debit <<  {:account_name => "store_#{company_id}",:amount =>  BigDecimal((store.to_f.round(2) - round_off_amount.to_f.round(2)).to_f.round(2).to_s), :company_id => company_id }
        debit << {:account_name => "order_round_off_#{company_id}",:amount => round_off_amount, :company_id => company_id }
      else
        debit <<  {:account_name => "store_#{company_id}",:amount => BigDecimal((store.to_f.round(2) - round_off_amount.to_f.round(2)).to_f.round(2).to_s), :company_id => company_id } if ((store).to_f.round(2) - round_off_amount.to_f.round(2)) > 0
      end
       # credit ==========================
      credit = []
      paid_from.each do |cr|
           l_name = cr["is_creditor"] == true ? "#{cr["name"].downcase.split(" ").join("_")}" : "#{cr["name"].downcase.split(" ").join("_")}_#{order.company_id}"
          # l_name = "#{cr["name"].downcase.split(" ").join("_")}"
          amount = BigDecimal((cr["value"].to_f.round(2)).to_s)
          credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
      end
      # puts "chak de"
      if round_off_amount < 0
        # credit << {:account_name => "store_#{company_id}",:amount => (round_off_amount).abs, :company_id => company_id }
        credit << {:account_name => "order_round_off_#{company_id}",:amount => (round_off_amount).abs, :company_id => company_id }
      end

      #   puts "debit =================="
      # debit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
      # puts "credit ==============="
      # credit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
      # debit_sum = debit.sum { |entry| entry[:amount].to_f.round(2) }
      # credit_sum = credit.sum { |entry| entry[:amount].to_f.round(2) }
      # puts "debit => #{debit_sum}, credit => #{credit_sum}"
      # puts "over all ==============="
      # puts "credit all ==============="
      #   credit.each do |c|
      #     puts "#{c[:account_name]} => #{c[:amount].to_f.round(2)}"
      #   end
      #   puts "Debit all ==============="
      #   debit.each do |c|
      #     puts "#{c[:account_name]} => #{c[:amount].to_f.round(2)}"
      #   end

      # puts ["cr",credit,"dr",debit, "is_equl" , debit_sum == credit_sum ]
      # credit side
      # erntry part
        round_message = "With Rounding adjustment"
        fixed_assets = assets > 0 ? "and order with Fixed asset Rs #{assets}" : ''
        @entry = Plutus::Entry.new(
          :description => "Purchase order Inv. #{order.invoice_no} Rs. #{order.grand_total.to_f.round(2)}  #{ round_message if (round_off_amount.present? && round_off_amount != 0) } #{ if service > 0 then ',service charges Rs. ' + service.to_s end} #{fixed_assets} ",
          :date => order.order_date,
          :commercial_document_type => Order,
          :commercial_document_id => order.id,
          :company_id => company_id,
          :debits => debit,
          :credits => credit
        )
        @entry.save!
        if(@entry.present?)
          order.update(is_processed:true, status: "processed")
        #   # puts "************ mera pahala plutus code ********************"
        end
      # erntry part

  end
  # Accounting::Order.store_credit_order
  def self.store_credit_order(order)
    # def self.store_credit_order
    # order = Order.find_by_id(436)
    company_id = order.company_id
    paid_from = order.paid_from
    assets = order.fixed_assets
    sold_assets_sum = assets.sum{|f| f.no_of_unit * f.unit_amount}.to_f.round(2)
    purchase_assets_temp = []
    assets.each do |sold_ent|
     unit_amout =  RecordFixedAsset.find_by_refrence_id(sold_ent.id).fixed_asset.record_fixed_assets.where(assets_type: "debit").first.unit_amount.to_f.round(2)
     purchase_assets_temp << (unit_amout * sold_ent.no_of_unit)
    end
    purchase_assets_sum = purchase_assets_temp.sum
    loss_on_sale_assets = purchase_assets_sum.to_f.round(2) - sold_assets_sum.to_f.round(2)

    service = BigDecimal(order.sale_service_transactions.sum(:amount).to_f.round(2).to_s)
    temp_gst_paid_old = order.gst_payble.to_f.round(2)
    gst_paid_old = BigDecimal(temp_gst_paid_old.to_f.round(2).to_s)
    o =  order.product_entries.map do |e|
      {
        sale: (e.net_unit_price * e.no_of_unit).to_f.round(2),
        purchase: (e.old_unit_price * e.no_of_unit).to_f.round(2),
      }
    end
    store = BigDecimal(o.sum { |entry| entry[:purchase] }.to_f.round(2).to_s)
    sale_revenue = BigDecimal(o.sum { |entry| entry[:sale] }.to_f.round(2).to_s)
    # store already ghata hua for round_off_amount or need to add
     round_off_amount = order.round_off_amount
    # debit side
    debit = []
    paid_from.each do |cr|
      # l_name = "#{cr["name"].downcase.split(" ").join("_")}_#{order.company_id}"
      l_name = cr["is_debtor"] == true ? "#{cr["name"].downcase.split(" ").join("_")}" : "#{cr["name"].downcase.split(" ").join("_")}_#{order.company_id}"
      amount = BigDecimal(cr["value"].to_f.round(2).to_s)
      debit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
    end
    debit <<    {:account_name => "cost_of_goods_sold_#{company_id}", :amount => BigDecimal((store).to_f.round(2).to_s), :company_id => company_id } if (store).to_f.round(2) > 0
    debit <<    {:account_name => "loss_on_sale_of_fixed_assets_#{company_id}", :amount => BigDecimal(loss_on_sale_assets.to_s), :company_id => company_id } if loss_on_sale_assets > 0
    if round_off_amount < 0
      debit << {:account_name => "order_round_off_#{company_id}",:amount => BigDecimal((round_off_amount).abs.to_s), :company_id => company_id }
    end
    # debit side
    credit = [ ]
    debit <<    {:account_name => "loss_on_sale_of_fixed_assets_#{company_id}", :amount => BigDecimal(loss_on_sale_assets.abs.to_s), :company_id => company_id } if loss_on_sale_assets < 0
    credit << {:account_name => "fixed_assets_#{company_id}",:amount => BigDecimal(purchase_assets_sum.to_f.round(2).to_s), :company_id => company_id } if purchase_assets_sum.to_f.round(2) > 0
    credit <<  {:account_name => "gst_payble_#{company_id}",:amount => gst_paid_old, :company_id => company_id } if gst_paid_old > 0
    credit << {:account_name => "service_charges_revenue_#{company_id}",:amount => service, :company_id => company_id } if service > 0
    credit <<  {:account_name => "sales_revenue_#{company_id}",:amount => sale_revenue, :company_id => company_id } if sale_revenue > 0
    if round_off_amount > 0
      credit <<  {:account_name => "store_#{company_id}",:amount => (store), :company_id => company_id }
      credit << {:account_name => "order_round_off_#{company_id}",:amount => round_off_amount.to_f.round(2), :company_id => company_id }
    else
      credit <<  {:account_name => "store_#{company_id}",:amount => (store), :company_id => company_id } if  (store) > 0
    end

    # puts "debit =================="
    #   debit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
    #   puts "credit ==============="
    #   credit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
      # debit_sum = debit.sum { |entry| entry[:amount].to_f.round(2) }
      # credit_sum = credit.sum { |entry| entry[:amount].to_f.round(2) }
      # puts "debit => #{debit_sum}, credit => #{credit_sum}"
      # puts "over all ==============="
      # puts "credit all ==============="
      #   credit.each do |c|
      #     puts "#{c[:account_name]} => #{c[:amount].to_f.round(2)}"
      #   end
      #   puts "Debit all ==============="
      #   debit.each do |c|
      #     puts "#{c[:account_name]} => #{c[:amount].to_f.round(2)}"
      #   end

      # puts ["cr",credit,"dr",debit, "is_equl" , debit_sum == credit_sum ]
      round_message = "With Rounding adjustment"
      @entry = Plutus::Entry.new(
        :description => "Sale order Inv. #{order.invoice_no} Rs. #{order.grand_total.to_f.round(2)}  #{ round_message if (round_off_amount.present? && round_off_amount != 0) } #{ if service > 0 then ',service charges Rs. ' + service.to_s end} #{ if sold_assets_sum > 0 then ',Fixed Assets Sold Rs. ' + sold_assets_sum.to_s end}",

        :date => order.order_date,
        :commercial_document_type => Order,
        :commercial_document_id => order.id,
        :company_id => company_id,
        :debits => debit,
        :credits => credit
      )
      @entry.save!
      if(@entry.present?)
        SoldProduct.where(order_id:order.id).update_all(is_active: true);
        order.update(is_processed:true,auto_approved: true, status: "processed")
        # puts "************ mera pahala plutus code ********************"
      end
    # erntry part
    # debit side end
  end
  # Accounting::Order.sale_return_order
  def self.sale_return_order(order)
    # def self.sale_return_order
    # order = Order.find_by_id(12)
    # order = Order.find_by_parent_order_id(order.id)
    khata_ac = Khatabook.find_by_id(order.khatabooks_id).ledger_name
    grand_total = BigDecimal(order.grand_total.to_f.round(2).to_s)
    order_gst = BigDecimal((order.gst_payble.to_f.round(2)).to_s)
    company_id = order.company_id
    round_off_amount = BigDecimal(order.round_off_amount.to_f.round(2).to_s)
    sale_return = order.product_entries.where(product_type: 'sale return').sum{|e| e.net_unit_price * e.no_of_unit}
    purchase = order.product_entries.where(product_type: 'debit').sum{|e| e.net_unit_price * e.no_of_unit}
    # return puts [sale_return, purchase]
    # debit

    debit = [ ]
    debit <<  {:account_name => "sales_revenue_#{company_id}",:amount => sale_return.to_f.round(2), :company_id => company_id }
    debit <<  {:account_name => "gst_payble_#{company_id}",:amount => order_gst, :company_id => company_id }
    debit << {:account_name => "store_#{company_id}",:amount => purchase , :company_id => company_id }
    if round_off_amount > 0
      debit << {:account_name => "order_round_off_#{company_id}",:amount => (round_off_amount).abs, :company_id => company_id }
    end
    # debit end
    # credit
    credit = []
    order.paid_from.each do |cr|
      if cr["name"] == "creditor"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        credit <<  {:account_name => "#{khata_ac}",:amount => amount, :company_id => company_id }
      else
        l_name = "#{cr["name"].downcase.split(" ").join("_")}_#{order.company_id}"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        credit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }

      end
    end
    credit <<  {:account_name => "cost_of_goods_sold_#{company_id}",:amount => purchase.to_f.round(2), :company_id => company_id }
    if round_off_amount < 0
      credit << {:account_name => "order_round_off_#{company_id}",:amount => (round_off_amount.to_f.round(2)).abs, :company_id => company_id }
    end


    #  puts "debit =================="
    #   debit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
    #   puts "credit ==============="
    #   credit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
    #   puts "over all ==============="
    #   debit_sum = debit.sum { |entry| entry[:amount].to_f.round(2) }
    #   credit_sum = credit.sum { |entry| entry[:amount].to_f.round(2) }
    #   # puts "credit: #{gst_paid_old + sale_revenue.to_f.round(2) + service + store}"
    #   puts ["cr",credit,"dr",debit, "is_equl" , debit_sum.to_f.round(2) == credit_sum.to_f.round(2), "credit #{credit_sum.to_f.round(2)}" , "debit #{debit_sum.to_f.round(2)}" ]
    #   puts credit_sum.to_f.round(2) - debit_sum.to_f.round(2)




    # credit end
      # erntry part
      round_message = "With Rounding adjustment"
      @entry = Plutus::Entry.new(
        :description => "Sale return order Inv. #{order.invoice_no} Rs. #{grand_total}  #{ round_message if (round_off_amount.present? && round_off_amount != 0) } ",
        :date => order.order_date,
        :commercial_document_type => Order,
        :commercial_document_id => order.id,
        :company_id => company_id,
        :debits => debit,
        :credits => credit
      )
      @entry.save!
      if(@entry.present?)
        order.update(is_processed:true, status: "processed")
        # puts "************ mera pahala plutus code ********************"
      end
    # erntry part


  end
  # Accounting::Order.purchase_return_order
  def self.purchase_return_order(order)
  # def self.purchase_return_order
    # order = Order.find_by_id(170)
    company_id = order.company_id
    khata_ac = Khatabook.find_by_id(order.khatabooks_id).ledger_name
    gst = BigDecimal((order.gst_paid).to_f.round(2).to_s)
    round_off_amount = BigDecimal(order.round_off_amount.to_f.round(2).to_s)
    o =  order.product_entries.map do |e|
      {
        purchase: (e.net_unit_price * e.no_of_unit).to_f.round(2),
      }
    end
    store = BigDecimal(o.sum { |entry| entry[:purchase] }.to_f.round(2).to_s)
    # debit side
    debit = []
    # [{"name": "cash book", "value": "1000", "is_debtor": false}, {"name": "creditor", "value": "180", "is_debtor": false}]
    order.paid_from.each do |cr|
      if cr["name"] == "creditor"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        debit <<  {:account_name => "#{khata_ac}",:amount => amount, :company_id => company_id }
      else
        l_name = "#{cr["name"].downcase.split(" ").join("_")}_#{company_id}"
        amount = BigDecimal(cr["value"].to_f.round(2).to_s)
        debit <<    {:account_name => l_name, :amount => amount, :company_id => company_id }
      end
    end
    if round_off_amount < 0
      debit << {:account_name => "order_round_off_#{company_id}",:amount => (round_off_amount).abs, :company_id => company_id }
    end
    # credit side
    credit = [ ]
    credit <<  {:account_name => "gst_paid_#{company_id}",:amount => gst, :company_id => company_id }
    if round_off_amount > 0
      credit <<  {:account_name => "store_#{company_id}",:amount => ((store).to_f.round(2)).to_f.round(2), :company_id => company_id }
      credit << {:account_name => "order_round_off_#{company_id}",:amount => round_off_amount.to_f.round(2), :company_id => company_id }
    else
      credit <<  {:account_name => "store_#{company_id}",:amount => (store).to_f.round(2), :company_id => company_id }
    end
    # puts "debit =================="
    #   debit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
    #   puts "credit ==============="
    #   credit.each{|v| puts "#{v[:account_name]}: #{v[:amount].to_f.round(2)}"}
    #   puts "over all ==============="
    #   debit_sum = debit.sum { |entry| entry[:amount] }
    #   credit_sum = credit.sum { |entry| entry[:amount] }
    #   # puts "credit: #{gst_paid_old + sale_revenue.to_f.round(2) + service + store}"
    #   puts ["cr",credit,"dr",debit, "is_equl" , debit_sum.to_f.round(2) == credit_sum.to_f.round(2), "credit #{credit_sum.to_f.round(2)}" , "debit #{debit_sum.to_f.round(2)}" ]
    #   puts credit_sum - debit_sum


    #  # erntry part
    round_message = "With Rounding adjustment"
    @entry = Plutus::Entry.new(
      :description => "Purchase return order Inv. #{order.invoice_no} Rs. #{order.grand_total.to_f.round(2)}  #{ round_message if (round_off_amount.present? && round_off_amount != 0) } ",

      :date => order.order_date,
      :commercial_document_type => Order,
      :commercial_document_id => order.id,
      :company_id => company_id,
      :debits => debit,
      :credits => credit
    )
    @entry.save!
    if(@entry.present?)
      order.update(is_processed:true, status: "processed")
      # puts "************ mera pahala plutus code ********************"
    end
  # erntry part



  end
  # delete all orders
  # Accounting::Order.delet_all_order
  def self.delet_all_order
    begin
      ActiveRecord::Base.transaction do
        Order.all.each do |o|
          # if o.order_type.downcase == 'credit'
          # SoldProduct.where(order_id: o.id).each {|t| t&.destroy!}
          o.fixed_assets.each do |f|
            f.record_fixed_assets.each{|r|r&.destroy!}
            f&.destroy!
          end
          o.product_entries.each do |e|
            e.sold_products.each {|s|s&.destroy!}
            e.returned_products.each {|r| r&.destroy!}
           e&.destroy!
          end
          o.sale_service_transactions.each {|t| t&.destroy!}
          o&.destroy!
          # end
        end
        Plutus::Entry.where(commercial_document_type: "Order").each do |e|
          e&.destroy!
        end

      end
      puts "**** all dong ****"
    rescue => e
      # Handle any exceptions
      # message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      puts e.message

      # return render json: { error: messa  ge, app_error: e.message }, status: :unprocessable_entity
    end

  end

  # Accounting::Order.delete_single_order(255)
  def self.delete_single_order(id)
    begin
      ActiveRecord::Base.transaction do
        o = Order.find_by_id(id)
         parent_order_id = o.is_returned ? o.parent_order_id : 0
          SoldProduct.where(order_id: o.id).each {|t| t&.destroy!}
          # o.product_entries.each {|t| t&.destroy!}
          o.product_entries.each do |e|
            e.returned_products.each {|r| r&.destroy!}
            e&.destroy!
          end
          o.sale_service_transactions.each {|t| t&.destroy!}

          Plutus::Entry.where(commercial_document_id: o.id, commercial_document_type: "Order").first&.destroy!
        if parent_order_id > 0
          ::Order.update_order_total(parent_order_id)
        end
        o&.destroy!
      end
      puts "**** all dong ****"
    rescue => e
      # Handle any exceptions
      # message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      puts e.message
      # return render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end


end
