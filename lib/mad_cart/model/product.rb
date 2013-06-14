module MadCart
  module Model
    class Product
      include MadCart::Model::Base

       required_attributes :name, :description, :image_url
    end
  end
end
