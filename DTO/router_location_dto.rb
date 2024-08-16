module DTO
  class RouterLocation
    attr_reader :routers, :locations

    def initialize(api_response)
      @routers = api_response['routers']&.map { |router| Router.new(router) }
      @locations = api_response['locations']&.map { |location| Location.new(location) }
    end

    class Router
      attr_reader :id, :location_id, :router_links

      def initialize(data)
        @id = data['id']
        @location_id = data['location_id']
        @router_links = data['router_links']
      end
    end

    class Location
      attr_reader :id, :name

      def initialize(data)
        @id = data['id']
        @name = data['name']
      end
    end
  end
end