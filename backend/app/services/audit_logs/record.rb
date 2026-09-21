module AuditLogs
  class Record
    def initialize(actor:, action:, auditable: nil, changes: {}, ip_address: nil)
      @actor = actor
      @action = action
      @auditable = auditable
      @metadata = changes
      @ip_address = ip_address
    end

    def call
      AuditLog.create!(
        actor: actor,
        action: action,
        auditable: auditable,
        metadata: metadata,
        ip_address: ip_address
      )
    end

    private

    attr_reader :actor, :action, :auditable, :metadata, :ip_address
  end
end
