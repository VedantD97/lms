class CreateQuizAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_attempts do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :quiz, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.integer :attempt_number, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.decimal :score, precision: 8, scale: 2
      t.decimal :max_score, precision: 8, scale: 2
      t.decimal :percentage, precision: 5, scale: 2
      t.boolean :passed
      t.datetime :started_at, null: false
      t.datetime :submitted_at
      t.datetime :expires_at
      t.integer :time_spent_seconds
      t.jsonb :question_order, null: false, default: []
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :quiz_attempts, :uuid, unique: true
    add_index :quiz_attempts, %i[quiz_id enrollment_id attempt_number], unique: true
    add_index :quiz_attempts, %i[enrollment_id status]
    add_check_constraint :quiz_attempts, "status >= 0 AND status <= 2", name: "quiz_attempts_status_check"
    add_check_constraint :quiz_attempts, "attempt_number >= 1", name: "quiz_attempts_attempt_number_check"
  end
end
