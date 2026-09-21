class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :status, null: false, default: 0
      t.datetime :email_verified_at
      t.datetime :last_sign_in_at

      t.timestamps
    end

    add_index :users, :uuid, unique: true
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :status
  end
end
