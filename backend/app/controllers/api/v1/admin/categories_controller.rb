module Api
  module V1
    module Admin
      class CategoriesController < BaseController
        before_action :set_category, only: %i[show update destroy]

        def index
          categories = policy_scope(Category).roots.includes(:children)
          records, meta = paginate(categories)
          authorize Category
          render_data(serialize_collection(records, serializer: Api::V1::CategorySerializer), meta: meta)
        end

        def show
          authorize @category
          render_data(serialize(@category, serializer: Api::V1::CategorySerializer))
        end

        def create
          category = Category.new(category_params)
          authorize category

          if category.save
            Cache::Keys.invalidate_categories!
            render_data(serialize(category, serializer: Api::V1::CategorySerializer), status: :created)
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(category))
          end
        end

        def update
          authorize @category

          if @category.update(category_params)
            Cache::Keys.invalidate_categories!
            render_data(serialize(@category, serializer: Api::V1::CategorySerializer))
          else
            render_record_invalid(ActiveRecord::RecordInvalid.new(@category))
          end
        end

        def destroy
          authorize @category
          @category.destroy!
          Cache::Keys.invalidate_categories!
          head :no_content
        end

        private

        def set_category
          @category = Category.find_by_uuid!(params[:uuid])
        end

        def category_params
          attrs = params.require(:category).permit(:name, :slug, :description, :position, :parent_uuid)
          if attrs[:parent_uuid].present?
            attrs[:parent_id] = Category.find_by_uuid!(attrs.delete(:parent_uuid)).id
          else
            attrs.delete(:parent_uuid)
          end
          attrs
        end
      end
    end
  end
end
