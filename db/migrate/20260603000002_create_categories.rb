class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string  :key,  null: false       # slug estable; lo referencian plan_items.category y day.slots
      t.string  :name
      t.string  :hex
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :categories, :key, unique: true
  end
end
