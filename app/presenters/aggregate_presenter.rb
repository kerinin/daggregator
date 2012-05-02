class AggregatePresenter
  include ActiveModel::SerializerSupport

  attr_accessor :identifier, :aggregates

  def initialize(node)
    @identifier = node.identifier
    @aggregates = {}
  end
end
