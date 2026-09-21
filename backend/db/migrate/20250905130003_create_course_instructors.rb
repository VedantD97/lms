class CreateCourseInstructors < ActiveRecord::Migration[8.0]
  def change
    create_table :course_instructors do |t|
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, null: false, default: 0

      t.timestamps
    end

    add_index :course_instructors, %i[course_id user_id], unique: true
    add_check_constraint :course_instructors, "role >= 0 AND role <= 1", name: "course_instructors_role_check"
  end
end
