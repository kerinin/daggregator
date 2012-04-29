require 'node_properties'

class Node
  attr_accessor :identifier

  def initialize(attrs)
    attrs.symbolize_keys!

    @identifier = attrs[:identifier]

    attrs[:data].try(:each_pair) do |key,value|
      data[key] = value
    end
  end

  def data
    @data ||= NodeProperties.new(identifier)
  end
end
