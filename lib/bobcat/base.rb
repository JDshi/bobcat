module Bobcat
  class Base


    class << self
      def service_method
        app_method = public_instance_methods(false).dup
        hdl_method = ancestors.select {|m| m.name.start_with?('Hdl::')}.map {|m| m.public_instance_methods(false)}
        app_method.concat(hdl_method).flatten
      end
    end
  end
end