require "spec_helper" 
require 'yapp/template'
include YAPP
=begin # this is a simple template

0|HEADER
1|table
2|thead     |a     |b     |c
3|row       |1
4|cell      |11        |
4|cell      |12        |
4|cell      |13        |
3|row       |2         |
4|cell      |21        |
4|cell      |22        |
4|cell      |23        |
9|2|rows    |5|cells   |
  
=end

describe Template do
  describe "template DSL" do
    before do
      @tpl = Template.new do
        first_char_at 1

        formatter :default do |v|
          v.strip!
        end

        model :header, /^0/ do
          field :type_id, 1
          field :desc, 10

          model :table, /^1/ do
            field :type_id, 1
            field :desc, 10
            model :thead, /^2/ do
            end
            model :row, /^3/ do
              model :cell, /^4/ do
                formatter :money, &:to_f
                formatter :date do |v|
                  begin
                    v.strip!
                    DateTime.strptime(v, '%Y%m%d') unless v.blank?
                  rescue
                    raise ArgumentError, "#{$!} DateTime.strptime(#{v} , '%Y%m%d') ; "
                  end
                end

              end
            end
          end
        end
        model :footer, /^9/
      end
    end

    it "requires a block" do
      @tpl.should be_instance_of(Template)
    end
    it "should have a root" do
      @tpl.root.should be_instance_of Model
    end

    it "should have two models at root" do
      @tpl.root.children.count.should == 2
    end

    describe "children" do
      it "should be an hash" do
        @tpl.root.children.should be_instance_of Hash
      end

      it "should map model name to model definition" do
        @tpl.root.children[:header].should be_instance_of Model
        @tpl.root.children[:header].children[:table].should be_instance_of Model
        @tpl.root.children[:header].children[:table].children[:row].should be_instance_of Model
        @tpl.root.children[:header].children[:table].children[:row].children[:cell].should be_instance_of Model
        @tpl.root.children[:header].children[:table].children[:foo].should be_nil
      end

      it "can have more then one child" do
        @tpl.root.children[:header].children[:table].children.count.should == 2
      end
      it "can have no children" do
        @tpl.root.children[:footer].children.count.should == 0
      end

      describe "field" do
        it "should have fields" do
          @tpl.root.children[:header].fields.count.should == 2
        end
      end
    end

    it "should have formatters for root" do
      @tpl.root.formatters.count.should == 1
    end

    it "should have formatters for any nested model" do
      @tpl.root.children[:header].children[:table].children[:row].formatters.count.should == 0
      @tpl.root.children[:header].children[:table].children[:row].children[:cell].formatters.count.should == 2
    end
  end
end


