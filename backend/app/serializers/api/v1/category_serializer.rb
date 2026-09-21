module Api
  module V1
    class CategorySerializer < ApplicationSerializer
      attributes :uuid, :name, :slug, :description, :position

      attribute :parent_uuid do |category|
        category.parent&.uuid
      end

      attribute :children do |category|
        category.children.order(:position, :name).map do |child|
          {
            uuid: child.uuid,
            name: child.name,
            slug: child.slug,
            description: child.description,
            position: child.position,
            parent_uuid: child.parent&.uuid
          }
        end
      end
    end
  end
end
