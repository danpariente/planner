class AccountsAndPerAccountData < ActiveRecord::Migration[8.1]
  PER_ACCOUNT = %i[days month_notes month_todos timetable_cells goals tasks materials categories].freeze

  DEFAULT_CATEGORIES = [
    ["cliente",  "Cliente",  "#5b82a8", 0],
    ["dev",      "Dev",      "#5e9c8f", 1],
    ["sc",       "SC:BW",    "#7e974f", 2],
    ["personal", "Personal", "#7c828c", 3],
    ["estudio",  "Estudio",  "#8c7bb3", 4],
    ["otro",     "Otro",     "#bd7e50", 5]
  ].freeze

  def up
    # 1) users -> accounts (+ FK de login_tokens)
    remove_foreign_key :login_tokens, :users
    rename_table :users, :accounts
    rename_column :login_tokens, :user_id, :account_id
    add_foreign_key :login_tokens, :accounts

    # 2) D-day pasa a la cuenta; la tabla settings desaparece
    add_column :accounts, :target_date, :date

    # 3) account_id en todos los modelos del planner
    PER_ACCOUNT.each { |t| add_reference t, :account, foreign_key: true }

    # 4) Backfill: todo lo existente -> cuenta dueña (la primera = dansification)
    owner_id = select_value("SELECT id FROM accounts ORDER BY id LIMIT 1")
    if owner_id
      PER_ACCOUNT.each do |t|
        execute("UPDATE #{t} SET account_id = #{owner_id} WHERE account_id IS NULL")
      end
      target = select_value("SELECT value FROM settings WHERE key = 'target_date' LIMIT 1")
      execute("UPDATE accounts SET target_date = #{quote(target)} WHERE id = #{owner_id}") if target
    end

    drop_table :settings

    # 5) Unicidad ahora por cuenta
    remove_index :days, :date
    add_index :days, [:account_id, :date], unique: true
    remove_index :month_notes, :on_date
    add_index :month_notes, [:account_id, :on_date], unique: true
    remove_index :timetable_cells, [:row, :col]
    add_index :timetable_cells, [:account_id, :row, :col], unique: true
    remove_index :categories, :key
    add_index :categories, [:account_id, :key], unique: true

    # 6) Categorías por defecto para cuentas que no tengan ninguna
    select_values("SELECT id FROM accounts").each do |aid|
      next if select_value("SELECT COUNT(*) FROM categories WHERE account_id = #{aid}").to_i.positive?
      DEFAULT_CATEGORIES.each do |key, name, hex, pos|
        execute(<<~SQL)
          INSERT INTO categories (account_id, key, name, hex, position, created_at, updated_at)
          VALUES (#{aid}, #{quote(key)}, #{quote(name)}, #{quote(hex)}, #{pos}, datetime('now'), datetime('now'))
        SQL
      end
    end
  end

  def down
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.timestamps
    end
    add_index :settings, :key, unique: true

    remove_index :categories, [:account_id, :key]
    add_index :categories, :key, unique: true
    remove_index :timetable_cells, [:account_id, :row, :col]
    add_index :timetable_cells, [:row, :col], unique: true
    remove_index :month_notes, [:account_id, :on_date]
    add_index :month_notes, :on_date, unique: true
    remove_index :days, [:account_id, :date]
    add_index :days, :date, unique: true

    PER_ACCOUNT.each { |t| remove_reference t, :account, foreign_key: true }
    remove_column :accounts, :target_date

    remove_foreign_key :login_tokens, :accounts
    rename_column :login_tokens, :account_id, :user_id
    rename_table :accounts, :users
    add_foreign_key :login_tokens, :users
  end
end
