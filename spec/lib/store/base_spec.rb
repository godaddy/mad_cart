require "spec_helper"

describe MadCart::Store::Base do
  before(:each) do
    Object.send(:remove_const, :MyStore) if Object.const_defined?(:MyStore)
    class MyStore; include MadCart::Store::Base; end
    class TestResult; end
  end

  describe "connection" do
    it "adds a create_connection_with method" do
      MyStore.should respond_to(:create_connection_with)
    end

    it "accepts a method reference" do
      MyStore.class_eval do
        create_connection_with :connection_method

        def connection_method(args={})
          return TestResult
        end
      end

      MyStore.new.connection.should == TestResult
    end

    it "accepts a proc" do
      MyStore.class_eval do
        create_connection_with Proc.new {|args| TestResult }
      end

      MyStore.new.connection.should == TestResult
    end

    it "raises an error if any required connection arguments are not present" do
      MyStore.class_eval do
        create_connection_with Proc.new { }, :requires => [:api_key, :username]
      end

      lambda { MyStore.new(:api_key => 'key').connection }.should raise_error(ArgumentError, "Missing connection arguments: username")
    end

    it "retrieves configured connection arguments" do
      class MyStore
        create_connection_with Proc.new { }, :requires => [:several, :args]
      end

      MadCart.configure do |config|
        config.add_store :my_store, {:several => 'of', :args => 'yes?'}
      end

      lambda { MyStore.new().connection }.should_not raise_error
    end

    it "retrieves a combination of configured and initialised connection arguments" do
      class MyStore
        create_connection_with Proc.new { }, :requires => [:several, :args]
      end

      MadCart.configure do |config|
        config.add_store :my_store, {:several => 'only'}
      end

      lambda { MyStore.new(:args => 'too').connection }.should_not raise_error
    end


  end

  describe "fetch" do
    it "adds a fetch method" do
      MyStore.should respond_to(:fetch)
    end

    it "accepts a method reference" do
      MyStore.class_eval do
        fetch :products, :with => :fetch_method

        def fetch_method
          return [{:some => 'attrs'}]
        end
      end

      result = double(MadCart::Model::Product)
      MadCart::Model::Product.should_receive(:new).with({:some => 'attrs'}).and_return(result)
      MyStore.new.products.should == [result]
    end

    it "accepts a proc" do
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [{:some => 'attrs'}, {:some => 'attrs'}] }
      end

      result = double(MadCart::Model::Product)
      MadCart::Model::Product.should_receive(:new).twice.with({:some => 'attrs'}).and_return(result)
      MyStore.new.products.should == [result, result]
    end

    it "converts hashes into instances of the mad cart model" do
      attrs = {"external_id" => 'id', "name" => "product name", "description" => 'product description', "price" => '12USD',
             "url" => 'path/to/product', "currency_code" => 'ZAR',
             "image_url" => 'path/to/image', "square_image_url" => 'path/to/square/image'}
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [attrs, attrs] }
      end

      MyStore.new.products.each{|p| p.should be_a(MadCart::Model::Product) }
    end

    it "returns instances of the mad cart model if the fetch method returns them" do
      attrs = {"external_id" => 'id', "name" => "product name", "description" => 'product description', "price" => '12USD',
             "url" => 'path/to/product', "currency_code" => 'ZAR',
             "image_url" => 'path/to/image', "square_image_url" => 'path/to/square/image'}
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [MadCart::Model::Product.new(attrs), MadCart::Model::Product.new(attrs)] }
      end

      MyStore.new.products.each{|p| p.should be_a(MadCart::Model::Product) }
    end

    it "returns instances of the mad cart model if the format method returns them" do
      attrs = {"external_id" => 'id', "name" => "product name", "description" => 'product description', "price" => '12USD',
             "url" => 'path/to/product', "currency_code" => 'ZAR',
             "image_url" => 'path/to/image', "square_image_url" => 'path/to/square/image'}
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [attrs, attrs] }
        format :products, :with => Proc.new {|p| MadCart::Model::Product.new(p) }
      end

      MyStore.new.products.each{|p| p.should be_a(MadCart::Model::Product) }
    end

    it "can be configured to retrieve additional attributes" do
      MadCart.configure do |config|
        config.include_attributes :products => [:external_id]
      end

      MyStore.class_eval do
        fetch :products, :with => Proc.new {   }
      end
    end
  end

  describe "format" do
    it "adds a format method" do
      MyStore.should respond_to(:format)
    end

    it "accepts a method reference" do
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [:one => 1] }
        format :products, :with => :format_method

        def format_method(product)
          return product
        end
      end

      store = MyStore.new
      store.should_receive(:format_method).with(:one => 1).and_return(double(MadCart::Model::Product))
      store.stub!(:ensure_model_format)
      store.products
    end

    it "accepts a proc" do
      MyStore.class_eval do
        fetch :products, :with => Proc.new { [1] }
        format :products, :with => Proc.new {|product| product.to_s }
      end

      store = MyStore.new
      store.should_receive(:ensure_model_format).with(:products, ["1"])
      store.products
    end
  end

  describe "initialize" do

    it "raises an exception on connection if initialize doesn't store the required connection args" do
      class MyStore
        create_connection_with Proc.new { }, :requires => [:args]

        def initialize
        end
      end

      o = MyStore.new
      lambda { o.connection }.should raise_error(MadCart::Store::SetupError,
          "It appears MyStore has overrided the default MadCart::Base initialize method. " +
          "That's fine, but please store any required connection arguments as @init_args " +
          "for the #connection method to use later. Remember to call #after_initialize " +
          "in your initialize method should you require it.")
    end
  end

  describe "after_initialize" do
    it "adds an after_initialize method" do
      MyStore.should respond_to(:after_initialize)
    end

    it "accepts a method reference" do
      MyStore.class_eval do
        after_initialize :init_method
        create_connection_with :connect_method

        def init_method(*args)
          @my_instance_var = args.first[:connection]
        end

        def connect_method(*args)
          return @my_instance_var
        end
      end

      MyStore.new(:connection => TestResult).connection.should == TestResult
    end

    it "accepts a proc" do
      MyStore.class_eval do
        after_initialize Proc.new {|arg| TestResult.new }
        create_connection_with :connect_method

        def connect_method(*args)
          return @my_instance_var
        end
      end

      TestResult.should_receive(:new)

      MyStore.new(:connection => TestResult)
    end
  end
end
