class AddGlobalDDay < ActiveRecord::Migration[8.1]
  def up
    create_table :settings do |t|
      t.string :key, null: false
      t.string :value
      t.timestamps
    end
    add_index :settings, :key, unique: true

    # El D-day pasa a ser global: si había algún target_date por día, usamos el
    # más reciente como objetivo global.
    existing = select_value(
      "SELECT target_date FROM days WHERE target_date IS NOT NULL ORDER BY date DESC LIMIT 1"
    )
    if existing
      execute(<<~SQL)
        INSERT INTO settings (key, value, created_at, updated_at)
        VALUES ('target_date', #{quote(existing)}, datetime('now'), datetime('now'))
      SQL
    end

    remove_column :days, :target_date
  end

  def down
    add_column :days, :target_date, :date
    drop_table :settings
  end
end
