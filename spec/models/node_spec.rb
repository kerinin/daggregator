require 'spec_helper'

describe Node do
  describe "new" do
    subject { Node.new( identifier: 'unique', data: { foo: 2, 'bar' => '3', baz: 4.1} ) }

    its(:identifier) { should == 'unique' }

    it "sets data keys" do
      subject.data[:foo].should == 2
    end
  end

  describe "save" do
  end

  describe "save!" do
  end

  describe "average" do
    context "with defined key" do
    end

    context "with undefined key" do
    end
  end

  describe "count" do
    context "with defined key" do
    end

    context "with undefined key" do
    end
  end
end
