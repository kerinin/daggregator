require 'spec_helper'

describe "flows/new" do
  before(:each) do
    assign(:flow, stub_model(Flow,
      :operations => "MyString"
    ).as_new_record)
  end

  it "renders new flow form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => flows_path, :method => "post" do
      assert_select "input#flow_operations", :name => "flow[operations]"
    end
  end
end
