ENV["NEO4J_URL"] ||= "http://localhost:7474"

uri = URI.parse(ENV["NEO4J_URL"])

$neo = Neography::Rest.new(uri.to_s)
$neo.create_node_index(:identifier)
$neo.create_relationship_index(:flow_node_pairs)

Neography::Config.tap do |c|
  c.server = uri.host
  c.port = uri.port

  if uri.user && uri.password
    c.authentication = 'basic'
    c.username = uri.user
    c.password = uri.password
  end
end
