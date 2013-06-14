require "spec_helper"

describe MadCart do
  
  it "allows configuration" do
    MadCart.configure do |config|
      config.should be_a(MadCart::Configuration)
      config.should be_a(Singleton)
    end
  end
  
  it "provides config values" do
    MadCart.config.should be_a(MadCart::Configuration::Data)
  end
  
  it "complains when the #config getter is used to set config values" do
    lambda do
      MadCart.config {|config| config.add_store :big_commerce }
    end.should raise_error(ArgumentError, "MadCart.config does not support blocks. Use MadCart.configure to set config values.")
  end
  
  it "complains if #configure is used incorrectly" do
    lambda { MadCart.configure }.should raise_error(ArgumentError, "MadCart.configure requires a block argument.")
  end  
end