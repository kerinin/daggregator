require 'spec_helper'

describe "flows/index" do
  before(:each) do
    assign(:flows, [
      stub_model(Flow,
        :operations => "Operations"
      ),
      stub_model(Flow,
        :operations => "Operations"
      )
    ])
  end

  it "renders a list of flows" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Operations".to_s, :count => 2
  end
end
