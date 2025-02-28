Rails.application.routes.draw do


  devise_for :users, controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
  }



  namespace "api" do
    namespace "v1" do
      resources :companies do
        collection do

          post :create_user, path: "create-new-user"
          get :get_users, path: "all-users"
          get :get_roles, path: "user-roles"
          post :set_roles, path: "set-roles"
          post :assign_roles, path: "assign-roles"
          get :get_user_associated_roles, path: "get-user-associated-roles"
          get :get_ledgers, path: "all-ledgers"
          get :get_ledgers_by_name, path: "all-ledgers-by-name"
          get :get_ledger_detail, path: "get-ledger-detail"
          get :get_entry_detail, path: "get-entry-detail"
          post :refresh_ledgers, path: "refresh-ledgers"
          post :company_bank_account, path: "company-bank-account"
          patch :update_company_bank_account, path: "update-company-bank-account"
          get :get_company_banks, path: "get-company-banks"
          get :product_units, path: "product-units"
        end
      end
      resources :employees do
        collection do
          get :nominee_relation, path: "nominee-relation"
          get :allowance_deduction_list, path: "allowance-deduction-list"
          post :create_salary, path: "create-salary"
          put :change_active_status_employee, path: "change-active-status-employee"
          get :employees_salary_disbursement, path: "employees-salary-disbursement"
          get :get_liquid, path: "get-liquid"
          get :get_active_employees, path: "get-active-employees"
          post :create_advance_salary, path: "create-advance-salary"

        end
      end
      resources :employee_salaries  do

        collection do
          get :get_disbursement_history, path: "get-disbursement-history"
          get :get_disbursement_history_details, path: "get-disbursement-history-details"
          get :get_advance_salary_payouts, path: "get-advance-salary-payouts"
        end
      end
      namespace "entries" do
        post :create_ledger, path: 'create-new-ledger'
        get :get_ledgers_by_type, path: 'get-ledgers-by-type'
        get :get_list_of_banks, path: 'get-list-of-banks'
        post :save_journal_entry, path: 'save-journal-entry'
        get :get_all_ledgers, path: 'get-all-ledgers'
        post :create_new_journal_entry, path: 'create-new-journal-entry'
        get :get_all_entries, path: 'get-all-entries'
        post :reverse_entry, path: 'reverse-entry'
        get :get_all_entries_plutus, path: 'get-all-entries-plutus'

      end
      resources "khatabooks" do
        collection do
        get :get_all_khatabooks, path: "get-all-khatabooks"
        get :get_all_khatabooks_drop, path: "get-all-khatabooks-drop"
        get :get_all_lenders, path: "get-all-lenders"
        post :change_active_status_khata, path: "change-active-status-khata"
        get :get_states, path: "get-states"
        get :khata_profile, path: "khata-profile"
        get :get_khata, path: "get-khata"
        end
      end
      namespace "store" do
        post :create_category, path: 'create-new-category'
        get :get_product_categories, path: 'product-categories'
        get :purchase_product_categories, path: 'purchase-product-categories'
        get :get_product_sale_categories, path: 'products-sale-categories'
        get :get_product_sale_products, path: 'get-sale-products'
        get :get_product_sale_products_mrps, path: 'get-sale-products-mrps'
        get :get_sale_product_unit_price, path: 'get-sale-products-unit-price'
        get :get_sale_products_available_units, path: 'get-sale-products-available-units'
        post :remove_temp_user_order_items, path: 'remove-temp-user-order-items'
        post :remove_temp_single_product, path: 'remove-temp-single-product'
        post :save_sale_order, path: 'save-sale-order'
        post :save_edit_sale_order, path: 'save-edit-sale-order'
        get :get_sold_product, path: 'get-sold-product'
        post :approve_bill, path: 'approve-bill'


        post :create_product, path: 'new-product'
        get :get_products, path: 'get-category-products'
        get :get_venders, path: 'get-venders'
        post :create_order, path: 'new-order'
        post :update_purchase_order, path: 'update-purchase-order'
        get :all_orders, path: 'all-order'
        get :get_order, path: 'order-order'

        post :get_all_products, path: 'get-all-products'

        post :create_return_order, path: 'create-return-order'
        get :edit_order_with_detail, path: 'edit-order-with-detail'
        post :remove_sale_edit_product, path: 'remove-sale-edit-product'
        post :add_product_items_sale_edit, path: 'add-product-items-sale-edit'



      end

      # resources :companies do
      #   collection do
      #     post :exl
      #     get :inactive
      #   end
      #   member do
      #     get :chutiya
      #     get :gandu
      #   end
      # #  get "testing", to: "testings#test"
      # end
      resources :promoters do
        collection do
          post :promoter_as_user, path: "new-promoter"
          get :promoters_with_share, path: "all-promoter-with-share"
          get :current_share_price, path: "current-share-price"
          post :add_shares_to_promoter, path: "add-shares-to-promoter"

        end

      end
      resources :khata_transactions do
        collection do
          get :khata_orders, path: "khata-orders"

        end
      end
      namespace :dashboard do
          get :stock_register, path: "stock-register"
          get :stock_summery, path: "stock-summery"
          get :company_trial_balance, path: "company-trial-balance"
          get :company_trial_balance_new, path: "company-trial-balance-new"
          get :daybook, path: "daybook"
          get :income_statement, path: "income-statement"
          get :get_all_products_dashboard, path: "get-all-products-dashboard"
      end
      namespace :expense do
        get :get_expense_category, path: "expense-category"
        post :save_expense_entry, path: "save-expense-entry"
        get :get_exp_entries, path: "get-exp-entries"
        get :get_exp_categories, path: "get-exp-categories"
        get :reverse_exp_entry, path: "reverse-exp-entry"
        patch :change_active_exp_categories, path: "change-active-exp-categories"
        post :save_expense_category, path: "save-expense-category"
      end

      resources "sale_services" do
        collection do
           get :get_sale_services_active, path: "get-sale-services-active"
        end
      end

      namespace :fixed_assets do
          get :all_fixed_assets, path: "all-fixed-assets"
          get :fixed_assets_sale, path: "fixed-assets-sale"
          post :fixed_assets_sale_save, path: "fixed-assets-sale-save"
          delete :delete_fixed_assets_sale, path: "delete-fixed-assets-sale/:id"
      end

    end
  end

end
