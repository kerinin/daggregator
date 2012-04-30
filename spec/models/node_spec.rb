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

  describe "Node.find_by_identifier" do
    before(:each) do
      Node.any_instance.stub(:fetch_node_attributes).and_return({})
    end

    it "instantiates a node" do
      Node.find_by_identifier('blah').should be_a(Node)
    end

    it "sets the identifier on the new node" do
      Node.find_by_identifier('blah').identifier.should == 'blah'
    end

    it "fetches attributes" do
      Node.any_instance.should_receive(:fetch_node_attributes)
      Node.find_by_identifier('blah')
    end
  end

  describe "set_node_properties" do
    # Integration test against neo4j
    subject { Node.new(:identifier => 'unique', :data => {:foo => 10}) }
    
    it "calls create_unique_node" do
      $neo.should_receive(:create_unique_node).with(:identifier, 'identifier', 'unique', {'foo' => 10} )
      subject.save!
    end

    it "sets properties on the node" do
      subject.save!
      Node.find_by_identifier('unique').data[:foo].should == 10
    end
  end

  describe "flow_to" do
    before(:each) do
      @source = Node.new(:identifier => 'source').save!
      @target = Node.new(:identifier => 'target').save!
      Flow.any_instance.stub(:save!).and_return(true)
    end

    it "instantiates a Flow object" do
      Flow.should_receive(:new).with(@source, @target)
      @source.flow_to(@target)
    end

    it "returns the created flow" do
      @source.flow_to(@target).should be_a(Flow)
    end
  end

  describe "flow_to!" do
    before(:each) do
      @source = Node.new(:identifier => 'source').save!
      @target = Node.new(:identifier => 'target').save!
    end

    it "calls flow_to" do
      @source.should_receive(:flow_to).with(@target).and_return(Flow.new(@source,@target))
      @source.flow_to!(@target)
    end

    it "saves the instantiated flow" do
      Flow.any_instance.should_receive(:save!)
      @source.flow_to!(@target)
    end
  end

  describe "aggregate_keys" do
    # Integration test against neo4j
  end

  describe "source_node_identifiers" do
    # Integration test against neo4j
  end

  describe "target_node_identifiers" do
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
