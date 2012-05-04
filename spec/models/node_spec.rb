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
      subject.should_receive(:save!).and_return(subject)
      subject.save
    end

    it "returns false on failure" do
      subject.stub(:save!).and_raise(StandardError)
      subject.save.should be_false
    end

    it "returns true on success" do
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
    before(:each) { @id = uuid }
    subject { Node.new(:identifier => @id, :data => {:foo => 10}) }
    
    it "calls create_unique_node" do
      $neo.should_receive(:create_unique_node).with(:identifier, 'identifier', @id, {'identifier' => @id, 'foo' => 10} )
      subject.save!
    end

    it "sets data on the node" do
      subject.save!
      Node.find_by_identifier(@id).data[:foo].should == 10
    end

    it "sets url on the node" do
      subject.save!
      Node.find_by_identifier(@id).node_url.should match(/db\/data\/node\/\d+/)
    end
  end

  describe "flow_to" do
    before(:each) do
      @source = Node.new(:identifier => uuid).save!
      @target = Node.new(:identifier => uuid).save!
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
      @source = Node.new(:identifier => uuid).save!
      @target = Node.new(:identifier => uuid).save!
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

  context "with aggregation data graph" do
    before(:each) do
      @h = Node.create(uuid)
      @g = Node.create(uuid).flow_to!(@h)
      @f = Node.create(uuid).flow_to!(@h)
      @e = Node.create(uuid).flow_to!(@f).flow_to!(@g)
      @d = Node.create(identifier: uuid, data: {value: 30}).flow_to!(@e)
      @c = Node.create(uuid).flow_to!(@e)
      @b = Node.create(uuid).flow_to!(@c)
      @a = Node.create(identifier: uuid, data: {value: 3, other: 100}).flow_to!(@b)
    end

    describe "upstream_sum" do
      it "aggregates source nodes" do
        @b.upstream_sum(:value).should == 3
      end

      it "aggregates sources of sources" do
        @c.upstream_sum(:value).should == 3
      end

      it "aggregates sources and sources of sources" do
        @e.upstream_sum(:value).should == 33
      end

      it "aggregates diamond shaped sources twice" do
        @h.upstream_sum(:value).should == 66
      end

      it "returns nil if key undefined" do
        @b.upstream_sum(:missing).should == nil
      end
    end

    describe "upstream_count" do
      it "aggregates source nodes" do
        @b.upstream_count(:value).should == 1
      end

      it "aggregates sources of sources" do
        @c.upstream_count(:value).should == 1
      end

      it "aggregates sources and sources of sources" do
        @e.upstream_count(:value).should == 2
      end

      it "aggregates diamond shaped sources twice" do
        @h.upstream_count(:value).should == 4
      end

      it "returns 0 if key missing" do
        @b.upstream_count(:missing).should == 0
      end
    end
  end
end
