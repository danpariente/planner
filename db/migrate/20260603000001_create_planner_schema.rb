class CreatePlannerSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :days do |t|
      t.date    :date, null: false
      t.date    :target_date          # para el contador D-
      t.decimal :goal_hours, precision: 4, scale: 1, default: 0.0
      t.integer :stars, default: 0
      t.text    :notes
      t.json    :slots, default: []   # 24 posiciones: id de categoría o null (idx 0 = 04:00)
      t.timestamps
    end
    add_index :days, :date, unique: true

    create_table :priorities do |t|
      t.references :day, null: false, foreign_key: true
      t.string  :body
      t.boolean :done, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :plan_items do |t|
      t.references :day, null: false, foreign_key: true
      t.string  :category, default: "cliente"
      t.string  :body
      t.boolean :done, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :month_notes do |t|
      t.date :on_date, null: false
      t.text :body
      t.timestamps
    end
    add_index :month_notes, :on_date, unique: true

    create_table :month_todos do |t|
      t.string  :period, null: false   # "2026-06"
      t.string  :body
      t.boolean :done, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :month_todos, :period

    create_table :timetable_cells do |t|
      t.integer :row, null: false      # 0..10
      t.integer :col, null: false      # 0..4 (Lun..Vie)
      t.string  :body
      t.timestamps
    end
    add_index :timetable_cells, [:row, :col], unique: true

    create_table :goals do |t|
      t.string  :area
      t.string  :target
      t.string  :previous
      t.string  :achieved
      t.boolean :done, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :tasks do |t|
      t.string  :category
      t.string  :body
      t.date    :due_on
      t.boolean :done, default: false, null: false
      t.integer :position, default: 0
      t.timestamps
    end

    create_table :materials do |t|
      t.string  :title
      t.integer :done_count, default: 0
      t.integer :total_count, default: 0
      t.integer :position, default: 0
      t.timestamps
    end
  end
end
