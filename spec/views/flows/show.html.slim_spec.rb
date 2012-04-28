require 'spec_helper'

describe "flows/show" do
  before(:each) do
    @flow = assign(:flow, stub_model(Flow,
      :operations => "Operations"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Operations/)
  end
end
