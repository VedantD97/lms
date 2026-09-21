class CreateLessonProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_progresses do |t|
      t.references :enrollment, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.decimal :progress_percent, precision: 5, scale: 2, null: false, default: 0.0
      t.integer :last_position_seconds, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :lesson_progresses, %i[enrollment_id lesson_id], unique: true
    add_index :lesson_progresses, :status
    add_check_constraint :lesson_progresses, "status >= 0 AND status <= 2", name: "lesson_progresses_status_check"
    add_check_constraint :lesson_progresses, "progress_percent >= 0 AND progress_percent <= 100",
                         name: "lesson_progresses_progress_percent_check"
    add_check_constraint :lesson_progresses, "last_position_seconds >= 0",
                         name: "lesson_progresses_last_position_seconds_check"
  end
end
