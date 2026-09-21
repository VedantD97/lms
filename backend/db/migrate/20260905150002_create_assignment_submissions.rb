class CreateAssignmentSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :assignment_submissions do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :assignment, null: false, foreign_key: true
      t.references :enrollment, null: false, foreign_key: true
      t.text :body
      t.datetime :submitted_at
      t.boolean :late, null: false, default: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :assignment_submissions, :uuid, unique: true
    add_index :assignment_submissions, %i[assignment_id enrollment_id], unique: true, name: "index_assignment_submissions_on_assignment_and_enrollment"
    add_index :assignment_submissions, :status
    add_check_constraint :assignment_submissions, "status >= 0 AND status <= 1", name: "assignment_submissions_status_check"
  end
end
