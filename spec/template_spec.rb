require "spec_helper" 
require 'yapp/template'
require 'yapp/generators/nokogiri'
require 'yapp/generators/hash'
include YAPP

simple_template =<<EOF
0|A HEADER
1|aniversarios                                  987987987987999
2|nome     telefone      nascimento     idade
3|romeu    555-22222     07/12/1980     32
3|juliana  555-55555     02/10/1984     28
3|gustavo  555-88888     12/10/2010     3
9|2|rows    |5|cells   |
EOF

describe Template do
  describe "template DSL" do
    before do
      @tpl = Template.new do
	first_char_at 0

        formatter :inteiro, &:to_i
        formatter :default do |v|
          v.strip        
        end



        model :header, /^0/ do
          field :type_id, 0..2
          field :desc, 10, :binary_proc

          formatter :binary_proc do |v, data|
            data[:desc].strip
          end

          model :table, /^1/ do
            field :type_id, 0..2
            field :desc, 20
            model :thead, /^2/ do
              field :campo1, 2..11
              field :campo2, 10
              field :campo3, 16
              field :campo4, 10
            end
            model :row, /^3/ do
              field :id, 2
              field :name, 9
              field :telefone, 14
              field :nascimento, 10, :date
              field :idade, 10, :inteiro
              formatter :money, &:to_f
              formatter :date do |v|
                  begin
                    v.strip!
                    DateTime.strptime(v, '%d/%m/%Y') unless v.nil? || v.empty?
                  rescue
                    raise ArgumentError, "#{$!} DateTime.strptime(#{v} , '%Y%m%d') ; "
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
      it "should be a hash" do
        @tpl.root.children.should be_instance_of Hash
      end

      it "should map model name to model definition" do
        @tpl.root.children[:header].should be_instance_of Model
        @tpl.root.children[:header].children[:table].should be_instance_of Model
        @tpl.root.children[:header].children[:table].children[:row].should be_instance_of Model
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
      @tpl.root.formatters.count.should == 2
    end

    it "should have formatters for any nested model" do
      @tpl.root.children[:header].children[:table].children[:row].formatters.count.should == 2
      @tpl.root.children[:header].children[:table].formatters.count.should == 0
    end

    it "should parse a simple template from string and return a hash" do
      YAPP::Generators::Hash.new.parse(@tpl, simple_template).should be_instance_of Hash
      YAPP::Generators::Hash.new.parse(@tpl, simple_template)[:children][:header].first[:children][:table].first[:attributes][:desc].should == 'aniversarios'
    end
    it "should parse a simple template from string and return a xml" do
      YAPP::Generators::Nokogiri.new.parse(@tpl, simple_template).should be_instance_of Nokogiri::XML::Element
      YAPP::Generators::Nokogiri.new.parse(@tpl, simple_template).to_xml(:indent => 0).gsub(/[\n]*/, '').split(/[< ]/).sort.should == '<root><header type_id="0|" desc="A HEADER"><table type_id="1|" desc="aniversarios"><thead campo1="nome" campo2="telefone" campo3="nascimento" campo4="idade"/><row id="3|" name="romeu" telefone="555-22222" nascimento="1980-12-07T00:00:00+00:00" idade="32"/><row id="3|" name="juliana" telefone="555-55555" nascimento="1984-10-02T00:00:00+00:00" idade="28"/><row id="3|" name="gustavo" telefone="555-88888" nascimento="2010-10-12T00:00:00+00:00" idade="3"/></table></header><footer/></root>'.split(/[< ]/).sort
    end
  end
end


