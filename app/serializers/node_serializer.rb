class NodeSerializer < ActiveModel::Serializer
  attributes :id, :data, :aggregates
end
