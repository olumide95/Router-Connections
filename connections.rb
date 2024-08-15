require 'httparty'
require 'set'
require 'json'

class RouterConnections
  API_URL = 'https://my-json-server.typicode.com/marcuzh/router_location_test_api/db'

  def self.fetch_data
    response = HTTParty.get(API_URL)
    if response.success?
      JSON.parse(response.body)
    else
      raise "Failed to fetch data from API"
    end
  end

  def self.find_location_connections
    data = fetch_data
    routers = data['routers']
    locations = data['locations']

    location_map = locations.map { |loc| [loc['id'], loc['name']] }.to_h
    router_map = routers.map { |router| [router['id'], router] }.to_h
    connections = Set.new

    routers.each do |router|
      router['router_links'].each do |linked_router_id|
        router_location = location_map[router['location_id']]
        linked_router = router_map[linked_router_id]
        next unless linked_router

        linked_location = location_map[linked_router['location_id']]

        if router_location != linked_location
          connectionsOutput = [router_location, linked_location].sort.join(' <-> ')
          connections.add(connectionsOutput)
        end
      end
    end

    connections
  end

  def self.find
    find_location_connections.each do |connection|
      puts connection
    end
  end
end

RouterConnections.find if __FILE__ == $0
