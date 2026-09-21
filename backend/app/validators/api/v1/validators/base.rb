module Api
  module V1
    module Validators
      class Base
        include ActiveModel::Model
        include ActiveModel::Validations

        def self.permitted_attributes
          attribute_names.map(&:to_sym)
        end
      end
    end
  end
end
