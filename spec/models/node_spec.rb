require 'spec_helper'

describe Node do
  describe "new" do
    subject { Node.new( data: { foo: 2, 'bar[]' => ['3',4.1,'5.1',6] } ) }

    it "sets numeric keys"  do
      subject.key(:foo).should == 2
    end

    it "sets set keys" do
      subject.key('bar[]').should == [3.0,4.1,5.1,6]
    end
  end
end
