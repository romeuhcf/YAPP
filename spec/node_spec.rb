require 'spec_helper'
require 'YAPP/node'

describe Node do
  describe "#nodes" do
    it "should be an array" do
      Node.new.nodes.should be_instance_of?(Array)
    end
  end
end
