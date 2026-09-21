class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :user, null: false, foreign_key: true
      t.integer :notification_type, null: false, default: 0
      t.jsonb :payload, null: false, default: {}
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, :uuid, unique: true
    add_index :notifications, :notification_type
    add_index :notifications, :read_at
    add_index :notifications, %i[user_id read_at]
    add_check_constraint :notifications, "notification_type >= 0 AND notification_type <= 3",
                         name: "notifications_notification_type_check"
  end
end
