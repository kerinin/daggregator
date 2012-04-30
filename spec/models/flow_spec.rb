require 'spec_helper'

describe Flow do
  describe "new" do
    before(:each) do
      @source = Node.new('source')
      @target = Node.new('target')
    end

    it "creates a flow" do
      Flow.new(@source, @target).should be_a(Flow)
    end
  end

  describe "save" do
    before(:each) do 
      @source = Node.new('source')
      @target = Node.new('target')
    end
    subject { Flow.new(@source, @target) }

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
    # NOTE: validations?
    
    before(:each) do
      @source = Node.new('source')
      @target = Node.new('target')
    end
    subject { Flow.new(@source, @target) }

    it "calls set_flow_properties" do
      subject.should_receive(:set_flow_properties)
      subject.save!
    end

    it "returns self on success" do
      subject.stub(:set_flow_properties).and_return(true)
      subject.save!.should == subject
    end

    it "raises error on failure" do
      subject.stub(:set_flow_properties).and_raise(StandardError)
      lambda { subject.save! }.should raise_error(StandardError)
    end
  end

  describe "set_flow_properties" do
    # Integration test
    before(:each) do
      @source = Node.new('source').save!
      @target = Node.new('target').save!
    end
    subject { Flow.new(@source, @target) }

    it "calls create_unique_relationship" do
      $neo.should_receive(:create_unique_relationship)
      subject.save!
    end

    it "creates the relationship" do
      subject.save!
      @source.target_identifiers.should include('target')
    end
  end
end
