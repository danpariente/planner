class AddLocaleToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :locale, :string, null: false, default: "es"
  end
end
