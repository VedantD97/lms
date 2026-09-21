class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.string :short_description
      t.integer :status, null: false, default: 0
      t.integer :level, null: false, default: 0
      t.integer :duration_minutes
      t.datetime :published_at
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :courses, :uuid, unique: true
    add_index :courses, :slug, unique: true
    add_index :courses, :status
    add_index :courses, %i[status published_at]
    add_check_constraint :courses, "status >= 0 AND status <= 2", name: "courses_status_check"
    add_check_constraint :courses, "level >= 0 AND level <= 2", name: "courses_level_check"
  end
end
