module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? && slug_source.present? }
  end

  private

  def generate_slug
    base = slug_source.to_s.parameterize
    return if base.blank?

    candidate = base
    counter = 1

    scope = self.class.where.not(id: id)
    while scope.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end

  def slug_source
    respond_to?(:title) ? title : name
  end
end
