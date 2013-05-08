# MadCart

Provides a unified API to various CRMs and online stores.
Simple configuration allows you to specify the properties you're interested in and what they're called.
A flexible DSL allows easy CRM and store integration.

Currently supports the following stores:
**-Etsy**
**-Bigcommerce**

## Installation

Add this line to your application's Gemfile:

    gem 'mad_cart'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mad_cart

## Usage

#### Credentials

Store/CRM credentials can be configured:

```ruby
MadCart.configure do |config|
  config.add_store :etsy, api_key: 'my-api-key', store_url: 'http://path.to/store'
end

store = MadCart::Store::Etsy.new
```
...or passed to the store initializer:

```ruby
store = MadCart::Store::Etsy.new(api_key: 'my-api-key', store_url: 'http://path.to/store')
```

### Products

```ruby
store = MadCart::Store::Etsy.new

store.products
#=> an array of MadCart::Model::Product objects
```

### Customers
```ruby
store = MadCart::Store::BigCommerce.new

store.customers
# => returns an array of MadCart::Model::Customer objects
```

### Attributes

Each model object has a property called attributes, which returns a hash. By default the following properties are returned:

**Customers:** *first_name*, *last_name*, and *email*
**Products:** *name*, *description*, and *image_url*

#### Additional Attributes

Any additional attributes returned by the CRM or store API will be stored in the *additional_attributes* property of the object.
MadCart allows you to include any of these additional attributes in the #attributes property of the model objects:

```ruby
store = MadCart::Store::Etsy.new

store.products.first.attributes
#=> {name: 'product name', description: 'product description', image_url 'http://path.to/image'}

MadCart.configure do |config|
  config.include_attributes products: [:external_id, :url]
end

store.products.first.attributes
#=> {name: 'product name', description: 'product description', image_url 'http://path.to/image', external_id: 42, url: 'http://path.to/store/products/42'}
```

#### Attribute Names

MadCart allows you to change the names of these attributes to match your existing field names:

```ruby
MadCart.configure do |config|
  config.attribute_map :products, {"name" => "title"}
end

store = MadCart::Store::Etsy.new

store.products.first.attributes
#=> {title: 'product name', description: 'product description', image_url 'http://path.to/image'}
```

This, in combination with declaring additional attributes, allows for very thin integration points without sacrificing customizability:

```ruby
store = MadCart::Store::Etsy.new
store.products.each{|p| MyProduct.create!(p.attributes) }
```

## Contributing

See the (Contributor's Guide)(https://github.com/madmimi/mad_cart/wiki/Contributor's-Guide) for info on the store integration API.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
