class CreateLessonResources < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_resources do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :lesson, null: false, foreign_key: true
      t.integer :resource_type, null: false, default: 0
      t.string :title, null: false
      t.string :external_url
      t.integer :position, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lesson_resources, :uuid, unique: true
    add_index :lesson_resources, %i[lesson_id position]
    add_check_constraint :lesson_resources, "resource_type >= 0 AND resource_type <= 4",
                         name: "lesson_resources_resource_type_check"
  end
end
