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
      before(:each) do
        @node = Node.new
        @node.stub(:data).and_return({data1: 1, data2: 2})
        @node.stub(:aggregates).and_return({aggregate1: 1, aggregate2: 2})
        Node.stub(:find).and_return(@node)
        get :show, id: 'foo', format: :json
      end

      it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
      it("returns 200") { response.status.should == 200 }

      it "returns expected JSON" do
        node = %({"node":{"data":{"data1":1, "data2":2}, "aggregates":{"aggregate1":1, "aggregate2":2}}})
        response.body.should be_json_eql(node)
      end
    end
  end

  describe "GET /node/<id>/key/<key>" do
    context "with existing node & data key" do
      before(:each) do
        @node = Node.new
        @node.stub(:data).and_return({'data_foo' => 1, 'data_baz.one' => 100, 'data_baz.two' => 200})
        @node.stub(:aggregates).and_return({'ag_foo' => 1, 'ag_bar' => [10,20,30], 'ag_baz.one' => 100, 'ag_baz.two' => 200})
        Node.stub(:find).and_return(@node)
      end

      context "requesting data key" do
        before(:each) { get :key, id: 1, key: 'data_foo', format: :json }

        it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
        it("returns 200") { response.status.should == 200 }
        it "returns expected JSON" do
          json = %({"data_foo": 1})
          response.body.should be_json_eql(json)
        end
      end

      context "requesting data namespace" do
        before(:each) { get :key, id: 1, key: 'data_baz', format: :json }

        it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
        it("returns 200") { response.status.should == 200 }
        it "returns expected JSON" do
          json = %({"data_baz.one": 100, "data_baz.two": 200})
          response.body.should be_json_eql(json)
        end
      end
      
      context "requesting numeric aggregate key" do
        before(:each) { get :key, id: 1, key: 'ag_foo', format: :json }

        it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
        it("returns 200") { response.status.should == 200 }
        it "returns expected JSON" do
          json = %({"ag_foo": 1})
          response.body.should be_json_eql(json)
        end
      end
      
      context "requesting set aggregate key" do
        before(:each) { get :key, id: 1, key: 'ag_bar', format: :json }

        it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
        it("returns 200") { response.status.should == 200 }
        it "returns expected JSON" do
          json = %({"ag_bar": [10,20,30]})
          response.body.should be_json_eql(json)
        end
      end

      context "requesting aggregate namespace" do
        before(:each) { get :key, id: 1, key: 'ag_baz', format: :json }

        it("returns JSON") { response.header['Content-Type'].should include 'application/json' }
        it("returns 200") { response.status.should == 200 }
        it "returns expected JSON" do
          json = %({"ag_baz.one": 100, "ag_baz.two":200})
          response.body.should be_json_eql(json)
        end
      end
    end

    context "with existing node, missing key" do
      before(:each) do
        @node = Node.new
        Node.stub(:find).and_return(@node)
      end

      it "raises RecordNotFound" do
        pending "not worth fighting"
        lambda { get :key, id: 1, key: 'does not exist', format: :json}.should raise_error(ActiveRecord::RecordNotFound)
      end
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
  end

  describe "DELETE /node/<id>/<key>" do
    context "with existing node and data key" do
    end

    context "with existing node without requested data key" do
    end

    context "with existing node and aggregate key" do
    end
  end

  describe "DELETE /node/<id>" do
    context "with existing node" do
    end
  end
end
