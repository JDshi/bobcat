require 'bobcat'

module Bobcat
  module Commands
    module ApplicationLoader
      def load_application
        %w(models services services/gen-rb).each do |dir|
          path = "#{Bobcat.root}/app/#{dir}"
          $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
        end

        require "#{Bobcat.root}/config/application"
        require "application_service"
      end
    end
  end
end
