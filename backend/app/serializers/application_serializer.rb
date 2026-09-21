class ApplicationSerializer
  include Alba::Resource

  def self.render(object, params: nil, **options)
    new(object, params: params, **options).serialize
  end
end
