module Api
  module V1
    class LessonProgressSerializer < ApplicationSerializer
      attributes :status, :progress_percent, :last_position_seconds, :started_at, :completed_at

      attribute :lesson_uuid do |progress|
        progress.lesson.uuid
      end
    end
  end
end
