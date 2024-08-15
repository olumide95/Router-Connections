# Router Location Connections

## Description

This Ruby project connects to a public REST API containing details of routers and their locations. It then outputs a list of connections between locations based on the router links.

## Prerequisites
- **Ruby 3.3.4 or later**
- **Rspec**
  
## Installation

```bash
$ gem install bundler
$ bundle install
```

## Running the script

```bash
$ ruby connections.rb

This will fetch data from the API and display all unique connections between locations in the format:
[Location Name] <-> [Location Name]
```

## Testing

```bash
$ rspec connections_spec.rb
```
