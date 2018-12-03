require 'spec_helper'

describe MadCart::Store::Base do # rubocop:disable Metrics/BlockLength
  before(:each) do
    Object.send(:remove_const, :MyStore) if Object.const_defined?(:MyStore)
    class MyStore; include MadCart::Store::Base; end
    class TestResult; end
  end

  describe 'connection' do # rubocop:disable Metrics/BlockLength
    it 'adds a create_connection_with method' do
      expect(MyStore).to respond_to(:create_connection_with)
    end

    it 'accepts a method reference' do
      MyStore.class_eval do
        create_connection_with :connection_method

        def connection_method(_args = {})
          TestResult
        end
      end

      expect(MyStore.new.connection).to eq(TestResult)
    end

    it 'accepts a proc' do
      MyStore.class_eval do
        create_connection_with(proc { |_args| TestResult })
      end

      expect(MyStore.new.connection).to eq(TestResult)
    end

    it 'raises an error if any required connection arguments are not present' do
      MyStore.class_eval do
        create_connection_with(proc {}, requires: %i[api_key username])
      end

      expect { MyStore.new(api_key: 'key').connection }
        .to raise_error(ArgumentError, 'Missing connection arguments: username')
    end

    it 'retrieves configured connection arguments' do
      class MyStore
        create_connection_with(proc {}, requires: %i[several args])
      end

      MadCart.configure do |config|
        config.add_store :my_store, several: 'of', args: 'yes?'
      end

      expect { MyStore.new.connection }.not_to raise_error
    end

    it 'retrieves combination configured & initialised connection arguments' do
      class MyStore
        create_connection_with(proc {}, requires: %i[several args])
      end

      MadCart.configure do |config|
        config.add_store :my_store, several: 'only'
      end

      expect { MyStore.new(args: 'too').connection }.not_to raise_error
    end
  end

  describe 'fetch' do # rubocop:disable Metrics/BlockLength
    it 'adds a fetch method' do
      expect(MyStore).to respond_to(:fetch)
    end

    it 'accepts a method reference' do
      MyStore.class_eval do
        fetch :products, with: :fetch_method

        def fetch_method
          [{ some: 'attrs' }]
        end
      end

      result = double(MadCart::Model::Product)
      expect(MadCart::Model::Product)
        .to receive(:new)
        .with(some: 'attrs')
        .and_return(result)
      expect(MyStore.new.products).to eq([result])
    end

    it 'accepts a proc' do
      MyStore.class_eval do
        fetch :products, with: proc { [{ some: 'attrs' }, { some: 'attrs' }] }
      end

      result = double(MadCart::Model::Product)
      expect(MadCart::Model::Product)
        .to receive(:new)
        .twice
        .with(some: 'attrs')
        .and_return(result)
      expect(MyStore.new.products).to eq([result, result])
    end

    it 'converts hashes into instances of the mad cart model' do
      attrs = {
        'external_id' => 'id',
        'name' => 'product name',
        'description' => 'product description',
        'price' => '12USD',
        'url' => 'path/to/product',
        'currency_code' => 'ZAR',
        'image_url' => 'path/to/image',
        'square_image_url' => 'path/to/square/image'
      }
      MyStore.class_eval do
        fetch :products, with: proc { [attrs, attrs] }
      end

      MyStore.new.products.each { |p| expect(p).to be_a(MadCart::Model::Product) }
    end

    it 'returns instances of the model if the fetch method returns them' do
      attrs = {
        'external_id' => 'id',
        'name' => 'product name',
        'description' => 'product description',
        'price' => '12USD',
        'url' => 'path/to/product',
        'currency_code' => 'ZAR',
        'image_url' => 'path/to/image',
        'square_image_url' => 'path/to/square/image'
      }
      MyStore.class_eval do
        fetch :products, with: proc {
          [
            MadCart::Model::Product.new(attrs),
            MadCart::Model::Product.new(attrs)
          ]
        }
      end

      MyStore.new.products.each do |p|
        expect(p).to be_a(MadCart::Model::Product)
      end
    end

    it 'returns instances of the model if the format method returns them' do
      attrs = {
        'external_id' => 'id',
        'name' => 'product name',
        'description' => 'product description',
        'price' => '12USD',
        'url' => 'path/to/product',
        'currency_code' => 'ZAR',
        'image_url' => 'path/to/image',
        'square_image_url' => 'path/to/square/image'
      }
      MyStore.class_eval do
        fetch :products, with: proc { [attrs, attrs] }
        format :products, with: proc { |p| MadCart::Model::Product.new(p) }
      end

      MyStore.new.products.each do |p|
        expect(p).to be_a(MadCart::Model::Product)
      end
    end

    it 'can be configured to retrieve additional attributes' do
      MadCart.configure do |config|
        config.include_attributes products: [:external_id]
      end

      MyStore.class_eval do
        fetch :products, with: proc {}
      end
    end
  end

  describe 'format' do # rubocop:disable Metrics/BlockLength
    it 'adds a format method' do
      expect(MyStore).to respond_to(:format)
    end

    it 'accepts a method reference' do
      MyStore.class_eval do
        fetch :products, with: proc { [one: 1] }
        format :products, with: :format_method

        def format_method(product)
          product
        end
      end

      store = MyStore.new
      expect(store)
        .to receive(:format_method)
        .with(one: 1)
        .and_return(double(MadCart::Model::Product))
      allow(store).to receive(:ensure_model_format)
      store.products
    end

    it 'accepts a proc' do
      MyStore.class_eval do
        fetch :products, with: proc { [1] }
        format :products, with: proc { |product| product.to_s }
      end

      store = MyStore.new
      expect(store).to receive(:ensure_model_format).with(:products, ['1'])
      store.products
    end
  end

  describe 'initialize' do
    it "raises an exception on connection if initialize doesn't store the " \
        'required connection args' do
      class MyStore
        create_connection_with proc {}, requires: [:args]

        def initialize; end
      end

      o = MyStore.new
      expect(-> { o.connection })
        .to raise_error(
          MadCart::Store::SetupError,
          'It appears MyStore has overrided the default MadCart::Base ' \
          "initialize method. That's fine, but please store any required " \
          'connection arguments as @init_args for the #connection method to ' \
          'use later. Remember to call #after_initialize in your initialize ' \
          'method should you require it.'
        )
    end
  end

  describe 'after_initialize' do # rubocop:disable Metrics/BlockLength
    it 'adds an after_initialize method' do
      expect(MyStore).to respond_to(:after_initialize)
    end

    it 'accepts a method reference' do
      MyStore.class_eval do
        after_initialize :init_method
        create_connection_with :connect_method

        def init_method(*args)
          @my_instance_var = args.first[:connection]
        end

        def connect_method(*_args)
          @my_instance_var
        end
      end

      expect(MyStore.new(connection: TestResult).connection).to eq(TestResult)
    end

    it 'accepts a proc' do
      MyStore.class_eval do
        after_initialize(proc { |_arg| TestResult.new })
        create_connection_with :connect_method

        def connect_method(*_args)
          @my_instance_var
        end
      end

      expect(TestResult).to receive(:new)

      MyStore.new(connection: TestResult)
    end
  end
end
