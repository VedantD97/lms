class CreateCourseModules < ActiveRecord::Migration[8.0]
  def change
    create_table :course_modules do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :course_modules, :uuid, unique: true
    add_index :course_modules, %i[course_id position]
    add_index :course_modules, :status
    add_check_constraint :course_modules, "status >= 0 AND status <= 1", name: "course_modules_status_check"
  end
end
