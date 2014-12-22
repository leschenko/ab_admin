require 'spec_helper'

describe AbAdmin do
  it 'should be a module' do
    expect(AbAdmin).to be_a(Module)
  end
  
  context 'configuration' do
    before(:each) do
      AbAdmin.setup do |c|
        c.flash_keys = [:test, :test2]
        c.title_splitter = ' -> '
        c.site_name = 'Test'
      end
    end
    
    it 'should store configuration' do
      expect(AbAdmin.flash_keys).to eq [:test, :test2]
      expect(AbAdmin.title_splitter).to eq ' -> '
      expect(AbAdmin.site_name).to eq 'Test'
    end
  end
end
