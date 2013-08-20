require 'spec_helper'

describe Header do
  it 'don\'t allow html' do
    header = create(:header, title: 'test <b>html</b>', h1: 'test <b>html</b>', keywords: 'test <b>html</b>',
                    description: 'test <b>html</b>', seo_block: 'test <b>html</b>')
    header.title.should == 'test html'
    header.h1.should == 'test html'
    header.keywords.should == 'test html'
    header.description.should == 'test html'
    header.seo_block.should == 'test html'
  end
end
