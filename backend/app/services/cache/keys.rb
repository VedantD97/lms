module Cache
  module Keys
    CATEGORIES_INDEX = "v1:categories:index"
    STUDENT_CATALOG_PREFIX = "v1:student:catalog"
    STUDENT_DASHBOARD_PREFIX = "v1:student:dashboard"
    INSTRUCTOR_DASHBOARD_PREFIX = "v1:instructor:dashboard"
    ADMIN_DASHBOARD_PREFIX = "v1:admin:dashboard"

    module_function

    def student_catalog(params)
      digest = Digest::SHA256.hexdigest(params.compact.sort.to_h.to_json)
      "#{STUDENT_CATALOG_PREFIX}:#{digest}"
    end

    def student_dashboard(user_uuid)
      "#{STUDENT_DASHBOARD_PREFIX}:#{user_uuid}"
    end

    def instructor_dashboard(user_uuid)
      "#{INSTRUCTOR_DASHBOARD_PREFIX}:#{user_uuid}"
    end

    def admin_dashboard(user_uuid)
      "#{ADMIN_DASHBOARD_PREFIX}:#{user_uuid}"
    end

    def invalidate_categories!
      Rails.cache.delete(CATEGORIES_INDEX)
    end
  end
end
