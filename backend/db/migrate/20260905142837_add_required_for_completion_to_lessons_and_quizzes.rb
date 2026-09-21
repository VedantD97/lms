class AddRequiredForCompletionToLessonsAndQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :required_for_completion, :boolean, null: false, default: true
    add_column :quizzes, :required_for_completion, :boolean, null: false, default: true

    add_index :lessons, :required_for_completion
    add_index :quizzes, :required_for_completion
  end
end
