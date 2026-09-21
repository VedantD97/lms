class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body
      t.timestamps
    end

    add_index :reviews, :uuid, unique: true
    add_index :reviews, %i[course_id user_id], unique: true
    add_index :reviews, :rating
    add_check_constraint :reviews, "rating >= 1 AND rating <= 5", name: "reviews_rating_check"
  end
end
