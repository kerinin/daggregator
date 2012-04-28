require 'spec_helper'

describe "flows/edit" do
  before(:each) do
    @flow = assign(:flow, stub_model(Flow,
      :operations => "MyString"
    ))
  end

  it "renders the edit flow form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => flows_path(@flow), :method => "post" do
      assert_select "input#flow_operations", :name => "flow[operations]"
    end
  end
end
