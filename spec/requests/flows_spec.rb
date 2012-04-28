require 'spec_helper'

describe "Flows" do
  describe "POST /flow" do
    context "creating new empty flow" do
    end

    context "creating new flow with valid operations" do
    end

    context "creating new flow with circular operations" do
    end

    context "creating new flow with missing source" do
    end

    context "creating new flow with missing target" do
    end

    context "creating new flow with undefined source key" do
      # Interesting - this could be an aggregate key which hasn't been generated yet...
    end
  end

  describe "GET /flow/<id>" do
    context "with existing flow" do
    end

    context "with missing flow" do
    end
  end

  describe "PUT /flow/<id>" do
    context "with existing flow and no data" do
    end

    context "with existing flow and new valid data" do
    end

    context "with existing flow and valid data updates" do
    end

    context "with existing flow and missing source key" do
    end

    context "with existing flow and circular operation" do
    end

    context "with missing flow" do
    end

    context "with exisitng flow and junk data" do
    end
  end

  describe "PUT /flow/<id>/<source key>:<target key>" do
    context "with existing flow and new valid operation" do
    end

    context "with existing flow and circular operation" do
    end

    context "with existing flow and missing source key" do
    end

    context "with missing flow" do
    end
  end

  describe "DELETE /flow/<id>/<source key>:<target key>" do
    context "with existing flow and operation" do
    end

    context "with existing flow and missing operation" do
    end

    context "with missing flow" do
    end
  end

  describe "DELETE /flow/<id>" do
    context "with existing flow" do
    end

    context "with missing flow" do
    end
  end
end
