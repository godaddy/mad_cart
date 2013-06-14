require "spec_helper"

describe MadCart::Model::Product do

  before(:each) do
    clear_config
  end

  it "returns the default attributes" do
    extra_attrs = {"external_id" => 'id', "price" => '12USD',
                   "url" => 'path/to/product', "currency_code" => 'ZAR',
                   "square_image_url" => 'path/to/square/image'}
    default_attrs = {"name" => "product name", "description" => 'product description',
                     "image_url" => 'path/to/image'}

    c = MadCart::Model::Product.new(default_attrs.merge(extra_attrs))

    c.attributes.should eql(default_attrs)
  end

  it "allows attribute names to be overwritten" do
    MadCart.configure do |config|
      config.include_attributes :products => [:square_image_url]
      config.attribute_map :products, {:square_image_url => :thumbnail,
                                      :name => :title}
    end

    attrs = {"description" => 'product description',
             "image_url" => 'path/to/image'}

    c = MadCart::Model::Product.new(attrs.merge(:name => "product name", :square_image_url => 'path/to/square/image'))

    c.attributes.should eql(attrs.merge("title" => "product name",
                                        "thumbnail" => 'path/to/square/image'))
  end

  it "exposes all additional attributes provided by the api" do
    attrs = {"name" => "product name", "description" => 'product description',
             "image_url" => 'path/to/image'}

    c = MadCart::Model::Product.new(attrs.merge(:with => 'some', :additional => 'fields'))

    c.additional_attributes.should eql({"with" => 'some', "additional" => 'fields'})
  end

  describe "validation" do

    before(:each) do
      @args = {:name => 'name',
               :external_id => 'external_id',
               :description => 'description',
               :price => 'price',
               :url => 'url',
               :currency_code => 'currency_code',
               :image_url => 'image_url',
               :squre_image_url => 'square_image_url'
      }
    end

    it "requires name" do
      @args.delete(:name)
      lambda{ MadCart::Model::Product.new(@args)  }.should raise_error(ArgumentError)
    end

    it "requires description" do
      @args.delete(:description)
      lambda{ MadCart::Model::Product.new(@args)  }.should raise_error(ArgumentError)
    end

    it "requires image_url" do
      @args.delete(:image_url)
      lambda{ MadCart::Model::Product.new(@args)  }.should raise_error(ArgumentError)
    end
  end
end
