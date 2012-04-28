require 'spec_helper'

describe NodesController do
  describe "POST /node" do
    context "creating new empty node" do
      before(:each) { post :create, format: :json }

      it("creates a new node") { assigns(:node).should be_a(Node) }
      it("persists the node") { assigns(:node).should be_persisted }

      it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
      it("returns 201") { response.status.should == 201 }

      it "returns expected JSON" do
        node = %({"node":{"data":{}, "aggregates":{}}})
        response.body.should be_json_eql(node)
      end
    end

    context "creating new empty node with explicit values" do
      def node_attrs
        { data: { foo: 2, 'bar[]' => [3,4,5] } }
      end

      before(:each) { post :create, format: :json, node: node_attrs }

      it("creates a new node") { assigns(:node).should be_a(Node) }
      it("persists the node") { assigns(:node).should be_persisted }
      
      it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
      it("returns 201") { response.status.should == 201 }

      it "returns expected JSON" do
        node = %({"node":{"data":{"foo":2.0, "bar[]":[3.0,4.0,5.0]}, "aggregates":{}}})
        response.body.should be_json_eql(node)
      end
    end
  end

  describe "GET /node/<id>" do
    context "with existing node" do
    end

    context "with missing node" do
    end
  end

  describe "GET /node/<id>/<key>" do
    context "with existing node & data key" do
    end
    
    context "with existing node & aggregate numeric key" do
    end

    context "with existing node & aggregate set key" do
    end

    context "with existing node, missing key" do
    end

    context "with missing node" do
    end
  end

  describe "PUT /node/<id>" do
    context "with existing node and no data" do
    end

    context "with existing node and new valid data" do
    end

    context "with existing node and valid data updates" do
    end

    context "with existing node and pre-existing aggregate key" do
    end

    context "with missing node" do
    end

    context "with existing node and junk data" do
    end
  end

  describe "PUT /node/<id>/<key>/<value>" do
    context "with existing node and new valid key/value" do
    end

    context "with existing node and conflicting new key/value" do
    end

    context "with existing node and updated data value" do
    end

    context "with existing node and updated aggregate value" do
    end

    context "with missing node" do
    end
  end

  describe "DELETE /node/<id>/<key>" do
    context "with existing node and data key" do
    end

    context "with existing node without requested data key" do
    end

    context "with existing node and aggregate key" do
    end

    context "with missing node" do
    end
  end

  describe "DELETE /node/<id>" do
    context "with existing node" do
    end

    context "with missing node" do
    end
  end
end
