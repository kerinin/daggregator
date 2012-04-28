require 'spec_helper'

describe "Nodes" do
  describe "POST /node" do
    context "creating new empty node" do
    end

    context "creating new empty node with explicit id" do
    end

    context "creating a new node with keys/values" do
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
