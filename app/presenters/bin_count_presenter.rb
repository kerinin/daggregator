class BinCountPresenter < AggregatePresenter
  def initialize(node, keys, bin_count)
    super(node)

    keys.split("+").each do |key|
      aggregates[key] = node.upstream_bin_count(key, bin_count)
    end
  end

  def to_json
    {bin_count: aggregates}.to_json
  end
end
