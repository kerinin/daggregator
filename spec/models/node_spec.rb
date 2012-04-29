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
    subject { Node.new( identifier: 'unique' ) }

    it "calls save!" do
      subject.should_receive(:save!).and_return(@node)
      subject.save
    end

    it "returns true on success" do
      subject.stub(:save!).and_raise(StandardError)
      subject.save.should be_false
    end

    it "returns false on failure" do
      subject.stub(:save!).and_return(subject)
      subject.save.should be_true
    end
  end

  describe "save!" do
    subject { Node.new( identifier: 'unique', data: { foo: 10.4 } ) }

    it "sets identifier property" do
      subject.should_receive(:set_node_properties) do |arg|
        arg['identifier'].should == 'unique'
      end
      subject.save!
    end

    it "sets data properties" do
      subject.should_receive(:set_node_properties) do |arg|
        arg['foo'].should == 10.4
      end
      subject.save!
    end

    it "returns self on success" do
      subject.stub(:set_node_properties).and_return(true)
      subject.save!.should == subject
    end

    it "raises error on failure" do
      subject.stub(:set_node_properties).and_raise(StandardError)
      lambda { subject.save! }.should raise_error(StandardError)
    end
  end

  describe "set_node_properties" do
    # Integration test against neo4j
  end

  describe "aggregate_keys" do
    # Integration test against neo4j
  end

  describe "average" do
    context "with defined key" do
      # Integration test against neo4j
    end

    context "with undefined key" do
    end
  end

  describe "count" do
    context "with defined key" do
      # Integration test against neo4j
    end

    context "with undefined key" do
    end
  end
end
