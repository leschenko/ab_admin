require 'spec_helper'

describe Sunrise::Views::SearchWrapper do
  before(:each) { @search = Sunrise::Views::SearchWrapper.new({:title => "Some title", :monkey => "green"}) }

  it "should generate attrs methods" do
    @search.title.should == "Some title"
    @search.monkey.should == "green"
  end
  
  it "should return empty key" do
    @search.to_key.should be_nil
    @search.to_model.should be_nil
  end
  
  it "should return model name" do
    Sunrise::Views::SearchWrapper.model_name.plural.should == "searches"
    Sunrise::Views::SearchWrapper.model_name.singular.should == "search"
    Sunrise::Views::SearchWrapper.model_name.param_key.should == "search"
  end
end
