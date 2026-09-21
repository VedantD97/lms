class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :enrolled_at, null: false
      t.datetime :completed_at
      t.decimal :progress_percent, precision: 5, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    add_index :enrollments, :uuid, unique: true
    add_index :enrollments, %i[user_id course_id], unique: true
    add_index :enrollments, :status
    add_check_constraint :enrollments, "status >= 0 AND status <= 3", name: "enrollments_status_check"
    add_check_constraint :enrollments, "progress_percent >= 0 AND progress_percent <= 100",
                         name: "enrollments_progress_percent_check"
  end
end
