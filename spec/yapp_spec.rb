require 'spec_helper'
require 'yapp'
describe "YAPP" do
  describe "parse" do
    it "should return a XML doc" do
      YAPP.parse("").should be_instance_of(Nokogiri::XML::Document)
    end
  end
end
