require 'spec_helper'

describe AbAdmin do
  it 'should be a module' do
    AbAdmin.should be_a(Module)
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
      AbAdmin.flash_keys.should == [:test, :test2]
      AbAdmin.title_splitter.should == ' -> '
      AbAdmin.site_name.should == 'Test'
    end
  end
end
