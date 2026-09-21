module Api
  module V1
    class QuizStatisticsSerializer < ApplicationSerializer
      attributes :uuid, :title

      attribute :total_attempts do |_quiz, params|
        params[:stats][:total_attempts]
      end

      attribute :completed_attempts do |_quiz, params|
        params[:stats][:completed_attempts]
      end

      attribute :average_score do |_quiz, params|
        params[:stats][:average_score]
      end

      attribute :pass_rate do |_quiz, params|
        params[:stats][:pass_rate]
      end

      attribute :average_percentage do |_quiz, params|
        params[:stats][:average_percentage]
      end

      attribute :unique_students do |_quiz, params|
        params[:stats][:unique_students]
      end
    end
  end
end
