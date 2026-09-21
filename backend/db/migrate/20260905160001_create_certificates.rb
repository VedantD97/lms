class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :enrollment, null: false, foreign_key: true
      t.string :certificate_number, null: false
      t.datetime :issued_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end

    add_index :certificates, :uuid, unique: true
    add_index :certificates, :certificate_number, unique: true
    add_index :certificates, :revoked_at
  end
end
