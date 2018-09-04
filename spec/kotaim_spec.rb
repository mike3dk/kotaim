# frozen_string_literal: true

RSpec.describe Kotaim do
  include WebMock::API

  it 'has a version number' do
    expect(Kotaim::VERSION).not_to be nil
  end

  it 'has get_tags_and_images class method' do
    ret = Kotaim::PostUtil.get_tags_and_images('', 'https://foo.com/bar.rss')
    expect(ret).to eq([])
  end

  it 'has collect_info_with_url class method' do
    stub_request(:get, "http://foo.com/rss")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Feedjira 2.2.0'
        }
      )
      .to_return(
        status: 200,
        body: '<rss xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" '\
          'xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:taxo="http://pur'\
          'l.org/rss/1.0/modules/taxonomy/" xmlns:activity="http://activitystr'\
          'ea.ms/spec/1.0/" version="2.0">
        </rss>', headers: {}
      )

    exp = {
      title: nil,
      url: nil,
      description: nil,
      generator: nil,
      rss_url: 'http://foo.com/rss'
    }

    ret = Kotaim::BlogUtil.collect_info_with_url('https://foo.com')
    expect(ret).to eq(exp)
  end
end
