module Api
  module AuditLogging
    extend ActiveSupport::Concern

    private

    def record_audit!(action:, auditable: nil, changes: {})
      AuditLogs::Record.new(
        actor: current_user,
        action: action,
        auditable: auditable,
        changes: changes,
        ip_address: request.remote_ip
      ).call
    end
  end
end
