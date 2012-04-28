require 'spec_helper'

describe "nodes/edit" do
  before(:each) do
    @node = assign(:node, stub_model(Node,
      :data => "MyString",
      :aggregates => "MyString"
    ))
  end

  it "renders the edit node form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => nodes_path(@node), :method => "post" do
      assert_select "input#node_data", :name => "node[data]"
      assert_select "input#node_aggregates", :name => "node[aggregates]"
    end
  end
end
