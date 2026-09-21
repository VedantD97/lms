class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :quiz, null: false, foreign_key: true
      t.integer :question_type, null: false, default: 0
      t.text :body, null: false
      t.decimal :points, precision: 5, scale: 2, null: false, default: 1.0
      t.integer :position, null: false, default: 0
      t.text :explanation
      t.timestamps
    end

    add_index :questions, :uuid, unique: true
    add_index :questions, %i[quiz_id position]
    add_check_constraint :questions, "question_type >= 0 AND question_type <= 2", name: "questions_question_type_check"
    add_check_constraint :questions, "points >= 0", name: "questions_points_check"
  end
end
