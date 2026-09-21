class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :body, null: false
      t.integer :audience, null: false, default: 0
      t.references :course, null: true, foreign_key: true
      t.datetime :published_at
      t.timestamps
    end

    add_index :announcements, :uuid, unique: true
    add_index :announcements, :audience
    add_index :announcements, :published_at
    add_check_constraint :announcements, "audience >= 0 AND audience <= 1", name: "announcements_audience_check"
  end
end
