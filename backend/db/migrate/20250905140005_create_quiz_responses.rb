class CreateQuizResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_responses do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :quiz_attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.jsonb :selected_option_uuids, null: false, default: []
      t.boolean :is_correct
      t.decimal :points_awarded, precision: 8, scale: 2
      t.timestamps
    end

    add_index :quiz_responses, :uuid, unique: true
    add_index :quiz_responses, %i[quiz_attempt_id question_id], unique: true
  end
end
