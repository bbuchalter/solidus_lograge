class SolidusLograge::Engine < Rails::Engine
  isolate_namespace SolidusLograge
  engine_name 'solidus_lograge'

  def self.activate
    Dir.glob(
      File.join(
        File.dirname(__FILE__),
        '../../app/**/*_decorator*.rb'
      )
    ) do |c|
      Rails.configuration.cache_classes ? require(c) : load(c)
    end
  end

  config.to_prepare(&method(:activate).to_proc)
end
