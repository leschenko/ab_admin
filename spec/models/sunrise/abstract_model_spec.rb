require 'spec_helper'

describe Sunrise::AbstractModel do
  describe "SunriseStructure" do
    it "should return resource_name" do
      SunriseStructure.resource_name.should == 'Structure'
    end
    
    it "should load structure model" do
      SunriseStructure.model.should == Structure
    end
    
    it "should not be abstract_class?" do
      SunriseStructure.should_not be_abstract_class
    end
    
    context "instance" do
      before(:each) do
        @params = { :structure => { :title => 'Some title', :slug => 'Some slug' } }
        @abstract_model = Sunrise::Utils.get_model("structures", @params)
      end
      
      it "should return valid attributes" do
        @abstract_model.current_list.should == :tree
        @abstract_model.scoped_path.should == 'structures'
        @abstract_model.model_name.should == Structure.model_name
      end
      
      it "should return record attrs" do
        @abstract_model.param_key.should == 'structure'
        @abstract_model.attrs.should == @params[:structure]
      end
      
      it "should return current list view" do
        @abstract_model.list_key.should == :list_tree
      end
      
      it "should not load parent record" do
        @abstract_model.parent_record.should be_nil
      end
      
      it "should get current list settings" do
        @abstract_model.list.should_not be_nil
      end
      
      it "should build new record" do
        structure = @abstract_model.build_record
        structure.should be_new_record
      end
      
      it "should update current list view" do
        model = Sunrise::Utils.get_model("structures", {:view => 'table'})
        model.current_list.should == :table
      end
    end
  end
  
  describe "SunrisePage" do
    it "should not have config for list" do
      SunrisePage.config.list.should == false
    end
    
    it "should load structure model" do
      SunriseStructure.model.should == Structure
    end
    
    context "instance" do
      before(:each) do
        @params = { :structure => { :main => 'Some main content', :sidebar => 'Some sidebar content' } }
        @abstract_model = Sunrise::Utils.get_model("pages", @params)
      end
      
      it "should not render list config" do
        @abstract_model.list.should == false
      end
    end
  end
  
  describe "SunriseUser" do
    it "should return empty list on not defined fields" do
      SunrisePage.config.sections[:list_export].should be_nil
    end
  end
end
