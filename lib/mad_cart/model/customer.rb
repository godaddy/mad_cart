module MadCart
  module Model
    class Customer
      include MadCart::Model::Base

      required_attributes :first_name, :last_name, :email
    end
  end
end
