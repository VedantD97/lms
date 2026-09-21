class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :course_module, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.integer :content_type, null: false, default: 2
      t.integer :duration_seconds
      t.integer :position, null: false, default: 0
      t.boolean :is_preview, null: false, default: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :lessons, :uuid, unique: true
    add_index :lessons, %i[course_module_id position]
    add_index :lessons, :status
    add_index :lessons, :is_preview
    add_check_constraint :lessons, "content_type >= 0 AND content_type <= 3", name: "lessons_content_type_check"
    add_check_constraint :lessons, "status >= 0 AND status <= 1", name: "lessons_status_check"
  end
end
