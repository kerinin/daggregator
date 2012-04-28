require 'spec_helper'

describe "nodes/index" do
  before(:each) do
    assign(:nodes, [
      stub_model(Node,
        :data => "Data",
        :aggregates => "Aggregates"
      ),
      stub_model(Node,
        :data => "Data",
        :aggregates => "Aggregates"
      )
    ])
  end

  it "renders a list of nodes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Data".to_s, :count => 2
    assert_select "tr>td", :text => "Aggregates".to_s, :count => 2
  end
end
