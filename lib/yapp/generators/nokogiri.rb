require 'nokogiri'
module YAPP
  module Generators
    class Nokogiri

      def parse(template, parseable)
        root = create_root
        current_node = root
        template.parse(parseable) do |evt, model, fields, line, lineno|
           if evt == :open
              current_node = create_node(model.name, current_node, line, lineno)
              add_fields(current_node, fields)
           elsif evt == :close
             current_node = current_node.parent
           end
        end
        root
      end

      def create_node(name, parent_node, raw_line, lineno)
        raise ArgumentError, "Blank name" unless name
        n = ::Nokogiri::XML::Node.new(name.to_s, parent_node ? parent_node.document : nil)
        n.parent = parent_node
        n
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
