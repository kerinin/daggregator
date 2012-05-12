class DistributionPresenter < AggregatePresenter
  def initialize(node, keys)
    super(node)

    keys.split("+").each do |key|
      aggregates[key] = node.upstream_distribution(key)
    end
  end

  def to_json
    {distribution: aggregates}.to_json
  end
end
