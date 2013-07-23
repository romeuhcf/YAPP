module YAPP
  module Generators 
    class Hash 
      def add_child(node, name, child)
        node[:children]||={}
        node[:children][name] ||=[]
        node[:children][name] << child
      end 
 
      def add_fields(node, field_hash)
        node[:fields] = field_hash
      end
 
      def create_node(name, parent_node, raw_line, lineno)
        { :type => name, 
          :lineno => lineno, 
          :path => [(parent_node ? parent_node[:path] : ''), name].join('/') ,
          :raw => raw_line,
          :parent => parent_node,
          :children => {},
          :model => self
        }
      end

      def create_root
        {}
      end

    end
  end
end
