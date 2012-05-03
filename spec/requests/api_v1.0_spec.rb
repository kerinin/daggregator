require 'spec_helper'

shared_examples "a successful JSON response" do
  it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
  it("returns 20X") { [200,201].should include(response.status) }
end

shared_examples "a successful JSON response containing" do |json|
  it_behaves_like "a successful JSON response"

  it "returns expected JSON" do
    response.body.should include_json(json)
  end
end

describe "nodes" do
  describe "GET /node/:id" do
    context "with existing node" do
      before(:each) do
        target1 = Node.create('foo')
        target2 = Node.create('bar')
        node = Node.create(identifier: 'unique', data: {data1: 1, data2: 2}).flow_to!(target1).flow_to!(target2)
        get 'nodes/unique', format: :json
      end

      json =<<-JSON
        {
        "identifier":"unique", 
         "data":{"data1":1, "data2":2}, 
         "targets":["foo","bar"]
        }
      JSON
      it_behaves_like "a successful JSON response containing", json
    end
  end

  context "with saved data" do
    before(:each) do
      @subject = Node.create('target')
      Node.create(identifier: 'source1', data: {'foo' => 3, 'bar' => 4}).flow_to!(@subject)
      Node.create(identifier: 'source2', data: {'foo' => 30, 'bar' => 40}).flow_to!(@subject)
    end
     
    describe "GET /node/:id/sum/:keys" do
      before(:each) do
        get 'nodes/target/sum/foo+bar+baz', format: :json
      end

      json = <<-JSON
        {
          "foo":33,
          "bar":44,
          "baz":null
        }
      JSON
      it_behaves_like "a successful JSON response containing", json
    end

    describe "GET /node/:id/count/:keys" do
      before(:each) do
        get 'nodes/target/count/foo+bar+baz', format: :json
      end

      json = <<-JSON
        {
          "foo": 2,
          "bar": 2,
          "baz":0
        }
      JSON
      it_behaves_like "a successful JSON response containing", json
    end
  end

  describe "PUT /node/:id" do
    context "creating new empty node" do
      before(:each) do
        put 'nodes/foo', format: :json
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      json = %({"identifier": "foo", "data":{}, "targets":[]})
      it_behaves_like "a successful JSON response containing", json
    end

    context "creating new empty node with explicit values" do
      def node_attrs
        { data: { bar: 2, 'baz' => 3 } }
      end

      before(:each) do
        put 'nodes/foo', :format => :json, :node => node_attrs
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      json = %({"identifier": "foo", "data":{"bar":2.0, "baz":3.0}, "targets":[]})
      it_behaves_like "a successful JSON response containing", json
    end

    context "with existing node and new data" do
      def node_attrs
        { data: { bar: 2, 'baz' => 3 } }
      end

      before(:each) do
        Node.create(identifier: 'node', data: {foo: 1, bar: 1})
        put 'nodes/node', :format => :json, :node => node_attrs
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      json = %({"identifier": "node", "data":{"foo":1.0, "bar":2.0, "baz":3.0}, "targets":[]})
      it_behaves_like "a successful JSON response containing", json
    end
  end

  # Later...
  # describe "PUT /node/:id/key/:key/:value" do
  #   context "with existing node and new valid key/value" do
  #   end

  #   context "with existing node and updated data value" do
  #   end
  # end

  describe "PUT /node/:source_id/flow_to/:target_id" do
    context "with existing source and target nodes" do
      before(:each) do
        Node.create('source')
        Node.create('target')
        put 'nodes/source/flow_to/target', format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates a new flow" do
        Node.new('source').target_identifiers.should include('target')
      end
    end

    context "with new nodes" do
      before(:each) do
        put 'nodes/source/flow_to/target', format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates the source node" do
        Node.new('source').should be_persisted
      end

      it "creates the target node" do
        Node.new('target').should be_persisted
      end

      it "creates a new flow" do
        Node.new('source').target_identifiers.should include('target')
      end
    end
  end

  describe "DELETE /node/:id/key/:key" do
    context "with existing node and data key" do
    end

    context "with existing node without requested data key" do
    end

    context "with existing node and aggregate key" do
    end
  end

  describe "DELETE /node/:source_id/flow_to/:target_id" do
  end

  describe "DELETE /node/:id" do
    context "with existing node" do
    end
  end
end
