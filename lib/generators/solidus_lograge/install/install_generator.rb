module SolidusLograge
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates", __FILE__)

      def copy_initializer
        template "lograge.rb", "config/initializers/lograge.rb"
      end
    end
  end
end
