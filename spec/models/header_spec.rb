require 'spec_helper'

describe Header do
  it 'don\'t allow html' do
    header = create(:header, title: 'test <b>html</b>', h1: 'test <b>html</b>', keywords: 'test <b>html</b>',
                    description: 'test <b>html</b>', seo_block: 'test html')
    expect(header.title).to eq 'test html'
    expect(header.h1).to eq 'test html'
    expect(header.keywords).to eq 'test html'
    expect(header.description).to eq 'test html'
    expect(header.seo_block).to eq 'test html'
  end
end
