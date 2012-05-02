class SumPresenter < AggregatePresenter
  def initialize(node, keys)
    super(node)

    keys.split("+").each do |key|
      aggregates[key] = node.upstream_sum(key)
    end
  end

  def to_json
    {sum: aggregates}.to_json
  end
end
