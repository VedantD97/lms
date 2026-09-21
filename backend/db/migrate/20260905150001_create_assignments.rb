class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :course, null: false, foreign_key: true
      t.references :lesson, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_at
      t.decimal :max_points, precision: 8, scale: 2, null: false, default: 100.0
      t.decimal :passing_score, precision: 5, scale: 2, null: false, default: 70.0
      t.boolean :allow_late, null: false, default: false
      t.boolean :allow_resubmit, null: false, default: true
      t.boolean :required_for_completion, null: false, default: true
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :assignments, :uuid, unique: true
    add_index :assignments, :status
    add_index :assignments, :required_for_completion
    add_index :assignments, :due_at
    add_check_constraint :assignments, "status >= 0 AND status <= 1", name: "assignments_status_check"
    add_check_constraint :assignments, "max_points >= 0", name: "assignments_max_points_check"
    add_check_constraint :assignments, "passing_score >= 0 AND passing_score <= 100", name: "assignments_passing_score_check"
  end
end
