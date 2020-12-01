# frozen_string_literal: true

RSpec.describe Kotaim do
  include WebMock::API

  it 'has a version number' do
    expect(Kotaim::VERSION).to be '0.2.0'
  end

  it 'has get_tags_and_images class method' do
    ret = Kotaim::PostUtil.get_tags_and_images('', 'https://foo.com/bar.rss')
    expect(ret).to eq([])
  end

  it 'has collect_info_with_url class method' do
    rss_url = "http://foo.com/rss"

    stub_request(:get, rss_url)
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'foo.com',
          'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
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
      rss_url: rss_url,
      image: nil
    }

    ret = Kotaim::BlogUtil.collect_info_with_url('https://foo.com')
    expect(ret).to eq(exp)
  end
end
