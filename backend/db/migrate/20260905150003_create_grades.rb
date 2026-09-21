class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :gradable, polymorphic: true, null: false
      t.decimal :points, precision: 8, scale: 2, null: false
      t.decimal :percentage, precision: 5, scale: 2, null: false
      t.boolean :passed, null: false, default: false
      t.text :feedback
      t.references :graded_by, null: false, foreign_key: { to_table: :users }
      t.datetime :graded_at, null: false
      t.timestamps
    end

    add_index :grades, :uuid, unique: true
    add_check_constraint :grades, "points >= 0", name: "grades_points_check"
    add_check_constraint :grades, "percentage >= 0 AND percentage <= 100", name: "grades_percentage_check"
  end
end
