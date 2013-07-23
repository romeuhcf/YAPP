require 'nokogiri'
module YAPP
  module Generators
    class Nokogiri
      def create_node(name, parent_node, raw_line, lineno)
        raise ArgumentError, "Blank name" unless name
        ::Nokogiri::XML::Node.new(name.to_s, parent_node ? parent_node.document : nil)
      end
      def add_fields(node, field_hash)
        field_hash.each do|k,v|
          node[k.to_s] = v.to_s
        end
      end
      def add_child(node, name, child) 
        node.add_child(child)
      end
      def create_root
        ::Nokogiri::XML::Node.new('root', ::Nokogiri::XML::Document.new)
      end
    end
  end
end
