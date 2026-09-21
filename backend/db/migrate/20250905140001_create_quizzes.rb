class CreateQuizzes < ActiveRecord::Migration[8.0]
  def change
    create_table :quizzes do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :course, null: false, foreign_key: true
      t.references :lesson, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :time_limit_minutes
      t.decimal :passing_score, precision: 5, scale: 2, null: false, default: 70.0
      t.integer :max_attempts, null: false, default: 1
      t.boolean :shuffle_questions, null: false, default: false
      t.boolean :shuffle_answers, null: false, default: false
      t.integer :status, null: false, default: 0
      t.integer :show_correct_answers, null: false, default: 0
      t.datetime :available_from
      t.datetime :available_until
      t.timestamps
    end

    add_index :quizzes, :uuid, unique: true
    add_index :quizzes, :status
    add_check_constraint :quizzes, "status >= 0 AND status <= 1", name: "quizzes_status_check"
    add_check_constraint :quizzes, "show_correct_answers >= 0 AND show_correct_answers <= 1", name: "quizzes_show_correct_answers_check"
    add_check_constraint :quizzes, "passing_score >= 0 AND passing_score <= 100", name: "quizzes_passing_score_check"
    add_check_constraint :quizzes, "max_attempts >= 0", name: "quizzes_max_attempts_check"
  end
end
