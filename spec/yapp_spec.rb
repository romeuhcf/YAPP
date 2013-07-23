require 'spec_helper'
require 'yapp'
describe "YAPP" do
  describe "parse return" do
    it "should be a XML doc" do
      YAPP.parse("",nil).should be_instance_of(Nokogiri::XML::Document)
    end
  end
  describe "simple parse" do
    before do
      @response = YAPP.parse("abc",nil)
    end
    it "should be a XML doc" do
      @response.should be_instance_of(Nokogiri::XML::Document)
    end
  end
end
