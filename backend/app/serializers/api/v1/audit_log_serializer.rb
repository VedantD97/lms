module Api
  module V1
    class AuditLogSerializer < ApplicationSerializer
      attributes :uuid, :action, :ip_address, :created_at

      attribute :changes do |audit_log|
        audit_log.metadata
      end

      attribute :actor do |audit_log|
        user = audit_log.actor
        {
          uuid: user.uuid,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end

      attribute :auditable do |audit_log|
        next unless audit_log.auditable

        record = audit_log.auditable
        {
          type: audit_log.auditable_type,
          uuid: record.respond_to?(:uuid) ? record.uuid : nil
        }
      end
    end
  end
end
