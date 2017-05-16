Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.keep_original_rails_log = true
  config.lograge.logger = ActiveSupport::Logger.new(
    "#{Rails.root}/log/lograge_#{Rails.env}.log"
  )
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    excluded_params = %w(controller action format id)
    {
      params: event.payload[:params].except(*excluded_params).to_s,
      env: Rails.env,
      timestamp: event.time.utc.iso8601,
      total: ((event.end - event.time) * 1000).to_f.round(2),
      ip: event.payload[:ip],
      host: event.payload[:host],
      user_agent: event.payload[:user_agent],
      masquerading_user: event.payload[:masquerading_user],
      order: event.payload[:order]
    }
  end
end
