require 'rspec'
require 'httparty'
require_relative './connections'

describe RouterConnections do
  let(:object) { RouterConnections }

  describe '.find_location_connections' do
    before do
      allow(object).to receive(:fetch_data).and_return(DTO::RouterLocation.new(api_response))
      object.instance_variable_set(:@data, nil)
      object.instance_variable_set(:@routers, nil)
      object.instance_variable_set(:@locations, nil)
      object.instance_variable_set(:@location_map, nil)
      object.instance_variable_set(:@router_map, nil)
    end

    context 'fetch_data raises an error' do
      before do
        allow(object).to receive(:fetch_data).and_raise(StandardError, "Failed to fetch data from API")
        allow(RouterConnections.logger).to receive(:error)
      end

      let(:api_response) do
        {}
      end

      it 'returns an empty result' do
        expect(object.logger).to receive(:error).with("Failed to fetch data from API")

        connections = object.find_location_connections
        expect(connections).to be_empty
      end
    end

    context 'single bi-directional connections' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [2] },
            { 'id' => 2, 'location_id' => 2, 'router_links' => [1] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' },
            { 'id' => 2, 'name' => 'London' }
          ]
        }
      end

      it 'returns the correct connection between locations' do
        connections = object.find_location_connections
        expect(connections).to contain_exactly('Chester <-> London')
      end
    end

    context 'multiple bi-directional connections from one router' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [2, 3] },
            { 'id' => 2, 'location_id' => 2, 'router_links' => [1] },
            { 'id' => 3, 'location_id' => 3, 'router_links' => [1] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' },
            { 'id' => 2, 'name' => 'London' },
            { 'id' => 3, 'name' => 'Birmingham' }
          ]
        }
      end

      it 'returns all unique connections' do
        connections = object.find_location_connections
        expect(connections).to contain_exactly(
          'Chester <-> London',
          'Birmingham <-> Chester'
        )
      end
    end

    context 'router connected to self' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [1] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' }
          ]
        }
      end

      it 'does not include self-connections' do
        connections = object.find_location_connections
        expect(connections).to be_empty
      end
    end

    context 'chained router connections' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [2] },
            { 'id' => 2, 'location_id' => 2, 'router_links' => [1, 3] },
            { 'id' => 3, 'location_id' => 3, 'router_links' => [2] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' },
            { 'id' => 2, 'name' => 'London' },
            { 'id' => 3, 'name' => 'Birmingham' }
          ]
        }
      end

      it 'correctly handles chain connections' do
        connections = object.find_location_connections
        expect(connections).to contain_exactly(
          'Chester <-> London',
          'Birmingham <-> London'
        )
      end
    end

    context 'no connections between routers' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [] },
            { 'id' => 2, 'location_id' => 2, 'router_links' => [] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' },
            { 'id' => 2, 'name' => 'London' }
          ]
        }
      end

      it 'returns an empty list' do
        connections = object.find_location_connections
        expect(connections).to be_empty
      end
    end

    context 'cross-linked routers connections' do
      let(:api_response) do
        {
          'routers' => [
            { 'id' => 1, 'location_id' => 1, 'router_links' => [2, 3] },
            { 'id' => 2, 'location_id' => 2, 'router_links' => [1, 3] },
            { 'id' => 3, 'location_id' => 3, 'router_links' => [1, 2] }
          ],
          'locations' => [
            { 'id' => 1, 'name' => 'Chester' },
            { 'id' => 2, 'name' => 'London' },
            { 'id' => 3, 'name' => 'Birmingham' }
          ]
        }
      end

      it 'returns all possible connections' do
        connections = object.find_location_connections
        expect(connections).to contain_exactly(
          'Chester <-> London',
          'Birmingham <-> Chester',
          'Birmingham <-> London'
        )
      end
    end

    context 'no data' do
      let(:api_response) do
        {
          'routers' => [],
          'locations' => []
        }
      end

      it 'returns an empty result' do
        connections = object.find_location_connections
        expect(connections).to be_empty
      end
    end
  end
end
