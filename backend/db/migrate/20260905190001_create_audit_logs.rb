class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :auditable_type
      t.bigint :auditable_id
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_address
      t.timestamps
    end

    add_index :audit_logs, :uuid, unique: true
    add_index :audit_logs, %i[auditable_type auditable_id]
    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
