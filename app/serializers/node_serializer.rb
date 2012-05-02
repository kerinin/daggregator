class NodeSerializer < ActiveModel::Serializer
  attributes :identifier, :data
  attribute :target_identifiers, :key => :targets
end
