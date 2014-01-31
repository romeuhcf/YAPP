module YAPP
  module Generators 
    class Hash 
      def parse(template, parseable)
        root = {:name => :root, :attributes => {}, :children => {}}
        current_node = root
        parent = nil
        template.parse(parseable) do |evt, model, fields, line, lineno|
           if evt == :open
              parent = current_node 
              current_node = {:name => model.name, :attributes => fields, :children =>{}}
              parent[:children][model.name]||=[]
              parent[:children][model.name] << current_node
           elsif evt == :close
             current_node = parent
           end
        end
        root

      end



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
