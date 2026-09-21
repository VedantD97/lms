class CreateQuestionOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :question_options do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :question, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :is_correct, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :question_options, :uuid, unique: true
    add_index :question_options, %i[question_id position]
  end
end
