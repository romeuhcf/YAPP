require "yapp/version"
require 'nokogiri'
module YAPP
  def self.parse(string)
    Nokogiri::XML::Document.new
  end
end
