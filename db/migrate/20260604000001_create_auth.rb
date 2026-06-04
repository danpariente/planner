class CreateAuth < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string   :code,       null: false   # OTP de 6 dígitos
      t.string   :token,      null: false   # token del magic link (urlsafe)
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.integer  :attempts,   null: false, default: 0
      t.timestamps
    end
    add_index :login_tokens, :token, unique: true
  end
end
