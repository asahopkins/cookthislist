require 'spec_helper'

describe Tag do
  fixtures :tags
  before do
    @tag = Tag.first
  end

  describe "tags as a whole" do
    it "should have 7 total tags" do
      Tag.count.should == 7
    end
  end

  subject { @tag }

  it { should respond_to(:links) }
  
end
