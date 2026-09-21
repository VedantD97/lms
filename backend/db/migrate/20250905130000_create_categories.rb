class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :categories, :uuid, unique: true
    add_index :categories, :slug, unique: true
    add_index :categories, :position
  end
end
