require 'spec_helper'

describe NodeProperties do
  describe "[]=" do
    subject { NodeProperties.new identifier: 'foo' }

    context "with symbol key, integer value" do
      before(:each) { subject[:foo] = 1 }
      
      it("stringifies the key") { subject.keys.should include('foo') }
      it("accepts symbol indexing") { subject[:foo].should be_true }
      it("sets the value") { subject['foo'].should == 1 }
    end

    context "with float value" do
      before(:each) { subject[:foo] = 2.1 }
      
      it("sets the value") { subject['foo'].should == 2.1 }
    end

    context "with string value" do
      before(:each) { subject[:foo] = '1' }

      it("converts to float") { subject['foo'].should == 1.0 }
    end

    context "with key defined on a source node" do
      it "raises error" do
        pending "implementation of neo4j, associations"

        lambda { subject[:foo] = 2 }.should raise_error(Daggregator::SourceKeyConflict)
      end
    end
  end
end
