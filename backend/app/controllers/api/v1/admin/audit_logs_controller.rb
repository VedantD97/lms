module Api
  module V1
    module Admin
      class AuditLogsController < BaseController
        before_action :set_audit_log, only: :show

        def index
          logs = policy_scope(AuditLog).includes(:actor, :auditable).recent
          records, meta = paginate(logs)
          authorize AuditLog
          render_data(serialize_collection(records, serializer: Api::V1::AuditLogSerializer), meta: meta)
        end

        def show
          authorize @audit_log
          render_data(serialize(@audit_log, serializer: Api::V1::AuditLogSerializer))
        end

        private

        def set_audit_log
          @audit_log = AuditLog.find_by_uuid!(params[:uuid])
        end
      end
    end
  end
end
