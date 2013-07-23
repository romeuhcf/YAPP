require "yapp/version"
require "yapp/template"
require 'nokogiri'
module YAPP
  def self.parse(string, template)
    Nokogiri::XML::Document.new
  end
end
