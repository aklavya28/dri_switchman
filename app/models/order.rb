class Order < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  has_many :product_entries
  has_many :sale_service_transactions
  has_many :fixed_assets
  # belongs_to :vender_detail, foreign_key: 'vender_id'
  belongs_to :khatabook, foreign_key: 'khatabooks_id'






  # def self.create_new_product
  #  puts "dfsdfsd"
  # end
  # Order.balance_available
  def self.balance_available
    debit = self.where(auto_approved: true, order_type: 'debit').sum("grand_total").to_f.round(2)
    credit = self.where(auto_approved: true, order_type: 'credit').sum("grand_total").to_f.round(2)
    amount = debit - credit
  end

  def slug_method
    [ ]
  end
  # Order.update_order_total(45)
  def self.update_order_total(order_id, data=[])
    order = Order.find_by_id(order_id)
    data = order.paid_from.present? ? order.paid_from : []
    # update porduct entries

    o_discount = order.discount_percent.to_f
    itemprofit = []


    order.product_entries.each do |e|
      gst_percent = e.product_description["gst"].to_i
      e_order = e.unit_price * e.no_of_unit.to_i
      e_discount = (e_order * o_discount / 100)
      e_order_amount = (e_order - e_discount)
      e_gst = e_order_amount * gst_percent / 100
      e_total = (e_gst + e_order_amount)
      e_net_unit_price = (e_order - e_discount) / e.no_of_unit.to_i

      if( order.order_type.downcase == "debit"  )
        e_item_profit = 0
      elsif( order.order_type.downcase == "credit" && order.is_returned )
        e_item_profit = 0
      else
        e_item_profit = ((e_net_unit_price * (e.no_of_unit).to_f.round(2)) - (e.old_unit_price * e.no_of_unit)).to_f.round(2)
      end
      itemprofit << e_item_profit
      # e.returned_products.each do |rp|
      #   ProductEntry.find_by_id(rp.return_order_entry_id).nil? and rp&.destroy!
      # end
      return_qty = ReturnedProduct.where(return_order_entry_id: e.id).sum(:quantity)
      # return_qty =  e.returned_products.sum(:quantity)
      e.update!(
        discount: e_discount,
        gst: e_gst,
        total: e_total.to_f.round(2),
        item_profit:  e_item_profit,
        is_returned:  return_qty >= e.no_of_unit ? true : false,
        returned_qty: return_qty,
        net_unit_price: e_net_unit_price
        )

        e.sold_products.where(entry_type: 'sale').each do |s|
          s&.update!(
            purchase_unit_price: e.p_unit_price_with_discount.to_f.round(2),
            sale_unit_price: e.unit_price.to_f.round(2),
            net_unit_price: e.old_unit_price.to_f.round(2),
            sale_net_unit_price: e.net_unit_price.to_f.round(2)
          )
        end
        e.sold_products.where(entry_type: 'purchase').each do |s|
          s&.update!(net_unit_price: e.net_unit_price.to_f.round(2))
        end

      end
    # update porduct entries

    if order.is_returned && order.order_type.downcase == 'debit'
      order_entries =   order.product_entries.where(product_type: 'sale return')
    else
      order_entries =   order.product_entries.where(product_type: ['credit', 'debit'])
    end

    order_services =  order.sale_service_transactions
    khata_no =  order.khatabook.ledger_name
    product_gst = order_entries.sum(:gst).to_f.round(2)

    product_discount = order_entries.sum(:discount).to_f.round(2)
    product_total =  order_entries.sum { |entry| entry.total }.to_f.round(2)
      # return puts product_total.to_f
    serv_gst = order_services.sum(:gst).to_f.round(2)
    serv_total = order_services.sum(:total).to_f.round(2)
    gst_payble = ( serv_gst + product_gst ).to_f.round(2)


    paid_from_data = data.length > 0 ? data : [{"name": "#{khata_no}", "value": (product_total + serv_total+ ( order.round_off_amount) ).to_f.round(2), "is_debtor": true}];

    # puts "product #{product_total}"
    state_gst_id = Company.find_by_id(order.company_id).state_gst_id
    khata_state_id = order.khatabook.state_id

     # assets
     assets_taxable = []
     assets_gst = []
     order.fixed_assets.each do |f|
       gst = f.gst.to_f.round(2)
       assets_taxable_single  = (f.no_of_unit * f.unit_amount).to_f.round(2)
       assets_gst_single = (assets_taxable_single * gst / 100).to_f.round(2)
       assets_taxable << assets_taxable_single
       assets_gst << assets_gst_single
     end
     assets_total = assets_taxable.sum + assets_gst.sum
     # assets
    # gst calculation including return orders
      gst_paid = 0.0
      gst_payable = 0.0

      if order.order_type.downcase == 'debit' && order.is_returned == false
          gst_paid = gst_payble.to_f.round(2) + assets_gst.sum
          gst_payable = 0
      elsif order.order_type.downcase == 'credit' && order.is_returned == false
          gst_payable = gst_payble.to_f.round(2) + assets_gst.sum
      elsif  order.order_type.downcase == 'debit' && order.is_returned == true
          gst_paid = 0
          gst_payable = product_gst.to_f.round(2) + assets_gst.sum
      elsif  order.order_type.downcase == 'credit' && order.is_returned == true
          gst_paid = product_gst.to_f.round(2) + assets_gst.sum
          gst_payable = 0
      end

      grand_total = (product_total + serv_total + assets_total + ( order.round_off_amount))
    # round_r_off = order.round_off_amount != 0 ? (grand_total.to_s.split(".").last).to_f : 0
     # gst calculation including return orders
    return order.update!(
      grand_total: grand_total,
      discount: product_discount.to_f.round(2),
      gst_payble: gst_payable,
      gst_paid: gst_paid,
      order_profit: order_entries.sum(:item_profit).to_f.round(2),
      paid_from: paid_from_data,
      is_igst: state_gst_id == khata_state_id ? false : true,
      # round_off_amount: round_r_off
    )
    # puts "order_cal: #{order}"
  end
  def self.update_sale_return_order_total(order_id, data=[])
    order = Order.find_by_id(order_id)
    data = order.paid_from.present? ? order.paid_from : []
    # update porduct entries
    o_discount = order.discount_percent
    itemprofit = []
    order.product_entries.each do |e|

      if e.product_type.downcase == 'debit'
        gst_percent = e.product_description["gst"].to_f.round(2)
        e_discount = 0
        e_order_amount = (e.unit_price * e.no_of_unit).to_f.round(2)
        e_gst = (e_order_amount*gst_percent/100).to_f.round(2)
        e_total = (e_gst + e_order_amount).to_f.round(2)
        e_net_unit_price = e.unit_price.to_f.round(2)
        e_item_profit = 0
      else
        gst_percent = e.product_description["gst"].to_f.round(2)
        e_discount = ((e.unit_price * e.no_of_unit)*o_discount/100).to_f.round(2)
        e_order_amount = ((e.unit_price * e.no_of_unit) - e_discount).to_f.round(2)
        e_gst = (e_order_amount*gst_percent/100).to_f.round(2)
        e_total = (e_gst + e_order_amount).to_f.round(2)
        e_net_unit_price = ((e.unit_price).to_f.round(2) - ( e.unit_price * o_discount / 100) ).to_f.round(2)
        e_item_profit = ((e_net_unit_price * (e.no_of_unit).to_f.to_i) - (e.old_unit_price * e.no_of_unit)).to_f.round(2)
        itemprofit << e_item_profit
      end
      return_qty = ReturnedProduct.where(return_order_entry_id: e.id).sum(:quantity)
      e.update!(
        discount: e_discount.to_f.round(2),
        gst: e_gst.to_f.round(2),
        total: e_total.to_f.round(2),
        item_profit:  e_item_profit.to_f.round(2),
        is_returned:  return_qty >= e.no_of_unit ? true : false,
        returned_qty: return_qty,
        net_unit_price: e_net_unit_price.to_f.round(2)
        )
      end
    # update porduct entries
    order_entries =   order.product_entries.where(product_type: 'sale return')

    khata_no =  order.khatabook.ledger_name
    product_gst = order_entries.sum(:gst).to_f.round(2)
    product_discount = order_entries.sum(:discount).to_f.round(2)
    product_total =  order_entries.sum { |entry| entry.total }.to_f.round(2)
      # return puts product_total.to_f
    paid_from_data = data.length > 0 ? data : [{"name": "#{khata_no}", "value": (product_total +  ( order.round_off_amount) ).to_f.round(2), "is_debtor": true}];

    # puts "product #{product_total}"
    state_gst_id = Company.find_by_id(order.company_id).state_gst_id
    khata_state_id = order.khatabook.state_id

    # gst calculation including return orders
      gst_paid = 0
      gst_payable = product_gst.to_f.round(2)


     # gst calculation including return orders
    return order.update!(
      grand_total: (product_total  + ( order.round_off_amount)),
      discount: product_discount.to_f.round(2),
      gst_payble: gst_payable,
      gst_paid: gst_paid,
      order_profit: order_entries.sum(:item_profit).to_f.round(2),
      paid_from: paid_from_data,
      is_igst: state_gst_id == khata_state_id ? true : false
    )
    # puts "order_cal: #{order}"
  end
  def self.round_to_two(num)
    (num * 100).round / 100.0
  end

end
