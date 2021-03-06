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

describe "API v1.0" do
  describe "GET /node/:id" do
    context "with existing node" do
      before(:each) do
        @target1 = Node.create(uuid)
        @target2 = Node.create(uuid)
        @subject = Node.create(identifier: uuid, data: {numeric_data1: 1, numeric_data2: '2', text_data: 'hello'})
        @subject.flow_to!(@target1)
        @subject.flow_to!(@target2)
        get "nodes/#{@subject.identifier}", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json =<<-JSON
          {
          "identifier":"#{@subject.identifier}",
           "data":{"numeric_data1":1, "numeric_data2":2.0, "text_data":"hello"}, 
           "targets":["#{@target1.identifier}","#{@target2.identifier}"]
          }
        JSON
        response.body.should include_json(json)
      end
    end
  end

  context "with saved data" do
    before(:each) do
      @subject = Node.create(uuid)
      Node.create(identifier: uuid, data: {'foo' => 3, 'bar' => '4', 'baz' => 'hello'}).flow_to!(@subject)
      Node.create(identifier: uuid, data: {'foo' => 30, 'bar' => '40', 'baz' => 'there'}).flow_to!(@subject)
    end
      
    describe "GET /node/:id/bin_count/:keys?bins=n" do
      before(:each) do
        get "nodes/#{@subject.identifier}/bin_count/foo+bar+baz?bins=2", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json =<<-JSON
        {
          "foo": {"[3.0,16.5)": 1, "[16.5,30.0]": 1},
          "bar": {"[4.0,22.0)": 1, "[22.0,40.0]": 1},
          "baz": null
        }
        JSON
        response.body.should include_json(json)
      end
    end

    describe "GET /node/:id/distribution/:keys" do
      before(:each) do
        get "nodes/#{@subject.identifier}/distribution/foo+bar+baz+qux", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json =<<-JSON
        {
          "foo": {"3": 1, "30": 1},
          "bar": {"4.0": 1, "40.0": 1},
          "baz": {"hello": 1, "there": 1},
          "qux":null
        }
        JSON
        response.body.should include_json(json)
      end
    end
    
    describe "GET /node/:id/sum/:keys" do
      before(:each) do
        get "nodes/#{@subject.identifier}/sum/foo+bar+baz+qux", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json =<<-JSON
        {
          "foo":33,
          "bar":44,
          "baz":null,
          "qux":null
        }
        JSON
        response.body.should include_json(json)
      end
    end

    describe "GET /node/:id/count/:keys" do
      before(:each) do
        get "nodes/#{@subject.identifier}/count/foo+bar+baz+qux", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json =<<-JSON
        {
          "foo": 2,
          "bar": 2,
          "baz":2,
          "qux":0
        }
        JSON
        response.body.should include_json(json)
      end
    end
  end

  describe "PUT /node/:id" do
    context "creating new empty node" do
      before(:each) do
        @id = uuid
        put "nodes/#{@id}", format: :json
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json = %({"identifier": "#{@id}", "data":{}, "targets":[]})
        response.body.should include_json(json)
      end
    end

    context "creating new empty node with explicit values" do
      def node_attrs
        { data: { bar: 2, 'baz' => '3', 'qux' => 'hello'} }
      end

      before(:each) do
        @id = uuid
        put "nodes/#{@id}", :format => :json, :node => node_attrs
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json = %({"identifier": "#{@id}", "data":{"bar":2.0, "baz":3.0, "qux":"hello"}, "targets":[]})
        response.body.should include_json(json)
      end
    end

    context "with existing node and new data" do
      def node_attrs
        { data: { bar: 2, 'baz' => 3, 'qux' => 'hello' } }
      end

      before(:each) do
        @id = uuid
        Node.create(identifier: @id, data: {foo: 1, bar: 1, qux: 'there'})
        put "nodes/#{@id}", :format => :json, :node => node_attrs
      end

      it("creates a new node") { assigns(:node).should be_a(Node) }

      it_behaves_like "a successful JSON response"

      it "returns expected JSON" do
        json = %({"identifier": "#{@id}", "data":{"foo":1.0, "bar":2.0, "baz":3.0, "qux":"hello"}, "targets":[]})
        response.body.should include_json(json)
      end
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
        @source = Node.create(uuid)
        @target = Node.create(uuid)
        put "nodes/#{@source.identifier}/flow_to/#{@target.identifier}", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates a new flow" do
        @source.target_identifiers.should include(@target.identifier)
      end
    end

    context "with new nodes" do
      before(:each) do
        @source_id = uuid
        @target_id = uuid
        put "nodes/#{@source_id}/flow_to/#{@target_id}", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates the source node" do
        Node.new(@source_id).should be_persisted
      end

      it "creates the target node" do
        Node.new(@target_id).should be_persisted
      end

      it "creates a new flow" do
        Node.new(@source_id).target_identifiers.should include(@target_id)
      end
    end
  end

  describe "PUT /node/:target_id/flow_from/:source_ids" do
    context "with existing source and target nodes" do
      before(:each) do
        @source = Node.create(uuid)
        @target = Node.create(uuid)
        put "nodes/#{@target.identifier}/flow_from/#{@source.identifier}", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates a new flow" do
        @source.target_identifiers.should include(@target.identifier)
      end
    end

    context "with new nodes" do
      before(:each) do
        @source_id = uuid
        @target_id = uuid
        put "nodes/#{@target_id}/flow_from/#{@source_id}", format: :json
      end

      it_behaves_like "a successful JSON response"

      it "creates the source node" do
        Node.new(@source_id).should be_persisted
      end

      it "creates the target node" do
        Node.new(@target_id).should be_persisted
      end

      it "creates a new flow" do
        Node.new(@source_id).target_identifiers.should include(@target_id)
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
