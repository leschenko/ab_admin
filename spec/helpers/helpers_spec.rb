require 'spec_helper'

describe AbAdmin::Views::Helpers, focus: true do
  context 'duplicate separators' do
    it 'replace hyphen' do
      @page_title = 'Test title - | Brand'
      render_title.should == 'Test title | Brand'
    end

    it 'replace dash' do
      @page_title = 'Test title — | Brand'
      render_title.should == 'Test title | Brand'
    end

    it 'replace dot' do
      @page_title = 'Test title. | Brand'
      render_title.should == 'Test title | Brand'
    end

    it 'replace comma' do
      @page_title = 'Test title , | Brand'
      render_title.should == 'Test title | Brand'
    end
  end
end
