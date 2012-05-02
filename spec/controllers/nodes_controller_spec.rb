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

describe NodesController do
  describe "GET /node/:id" do
    context "with existing node" do
      before(:each) do
        target1 = Node.create('foo')
        target2 = Node.create('bar')
        node = Node.create(identifier: 'unique', data: {data1: 1, data2: 2}).flow_to!(target1).flow_to!(target2)
        get :show, id: 'unique', format: :json
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

  describe "GET /node/:id/sum/:keys" do
    before(:each) do
      @subject = Node.create('target')
      Node.create(identifier: 'source1', data: {'foo' => 3, 'bar' => 4}).flow_to!(@subject)
      Node.create(identifier: 'source2', data: {'foo' => 30, 'bar' => 40}).flow_to!(@subject)
      get :sum, id: 'target', keys: 'foo+bar+baz', format: :json
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
    context "with defined keys" do
    end

    context "with undefined key" do
      json = %({"node":{"identifier":'foo', "aggregates":{"bar": {"COUNT": 0}}}})
      it_behaves_like "a successful JSON response containing", json
    end
  end

  describe "PUT /node/:id" do
    context "creating new empty node" do
      before(:each) { post :create, format: :json, id: 'foo' }

      it("creates a new node") { assigns(:node).should be_a(Node) }
      it("persists the node") { assigns(:node).should be_persisted }

      json = %({"node":{"identifier": "foo", "data":{}, "aggregates":{}}})
      it_behaves_like "a successful JSON response containing", json
    end

    context "creating new empty node with explicit values" do
      def node_attrs
        { data: { bar: 2, 'baz' => 3 } }
      end

      before(:each) { post :create, format: :json, id: 'foo', node: node_attrs }

      it("creates a new node") { assigns(:node).should be_a(Node) }
      it("persists the node") { assigns(:node).should be_persisted }

      json = %({"node":{"identifier": "foo", "data":{"bar":2.0, "baz":3.0}, "aggregates":{}}})
      it_behaves_like "a successful JSON response containing", json
    end

    context "with existing node and no data" do
    end

    context "with existing node and new valid data" do
    end
  end

  describe "PUT /node/:id/key/:key/:value" do
    context "with existing node and new valid key/value" do
    end

    context "with existing node and updated data value" do
    end
  end

  describe "PUT /node/:source_id/flow_to/:target_id" do
    context "with existing source and target nodes" do
    end

    context "with existing source node and missing target" do
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
