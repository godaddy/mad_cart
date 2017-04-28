require 'spec_helper'

describe MadCart do
  it 'allows configuration' do
    MadCart.configure do |config|
      expect(config).to be_a(MadCart::Configuration)
      expect(config).to be_a(Singleton)
    end
  end

  it 'provides config values' do
    expect(MadCart.config).to be_a(MadCart::Configuration::Data)
  end

  it 'complains when the #config getter is used to set config values' do
    expect(-> { MadCart.config { |config| config.add_store :big_commerce } })
      .to raise_error(ArgumentError, 'MadCart.config does not support ' \
                                     'blocks. Use MadCart.configure to ' \
                                     'set config values.')
  end

  it 'complains if #configure is used incorrectly' do
    expect(-> { MadCart.configure })
      .to raise_error(ArgumentError,
                      'MadCart.configure requires a block argument.')
  end
end
