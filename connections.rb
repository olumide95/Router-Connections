require 'httparty'
require 'set'
require 'json'
require 'logger'
require_relative 'DTO/router_location_dto'

class RouterConnections
  API_URL = 'https://my-json-server.typicode.com/marcuzh/router_location_test_api/db'

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.fetch_data
    response = HTTParty.get(API_URL)
    if response.success?
      json_response = JSON.parse(response.body)
      DTO::RouterLocation.new(json_response)
    else
      raise "Failed to fetch data from API"
    end
  end

  def self.data
    begin
      @data ||= fetch_data
      return @data
    rescue StandardError => e
      logger.error(e.message)
    end
    DTO::RouterLocation.new({})
  end

  def self.routers
    @routers ||= data.routers
  end

  def self.locations
    @locations ||= data.locations
  end

  def self.location_map
    @location_map ||= locations.map { |loc| [loc.id, loc.name] }.to_h
  end

  def self.router_map
    @router_map ||= routers.map { |router| [router.id, router] }.to_h
  end

  def self.find_location_connections
    connections = Set.new

    routers&.each do |router|
      router.router_links.each do |linked_router_id|
        router_location = location_map[router.location_id]
        linked_router = router_map[linked_router_id]
        next unless linked_router

        linked_location = location_map[linked_router.location_id]

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
