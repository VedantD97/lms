module Identifiable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_uuid, on: :create
  end

  class_methods do
    def find_by_uuid!(uuid)
      find_by!(uuid: uuid)
    end
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
