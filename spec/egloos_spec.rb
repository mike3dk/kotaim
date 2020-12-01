# frozen_string_literal: true

RSpec.describe 'egloos' do
  include WebMock::API

  context 'when handling egloos blog' do
    before do
      @blogger_url = 'http://kcanari.egloos.com'
      @blogger_rss_url = 'http://rss.egloos.com/blog/kcanari'

      egloos_rss_sample = File.open('spec/fixtures/egloos_rss_sample.xml').read
      stub_request(:get, "http://rss.egloos.com/blog/kcanari")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'rss.egloos.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: egloos_rss_sample, headers: {})

      egloos_post_sample = File.open('spec/fixtures/egloos_post_sample.html').read
      stub_request(:get, "http://kcanari.egloos.com/4175078")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'kcanari.egloos.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: egloos_post_sample, headers: {})
    end

    it 'collects good blog information' do
      exp = {
        description: "까날의 일본 먹거리 여행기\nkcanari@gmail.com",
        generator: "Egloos",
        image: "http://pds1.egloos.com/logo/1/200608/28/17/a0008417.jpg",
        rss_url: "http://rss.egloos.com/blog/kcanari",
        title: "일본에 먹으러가자.",
        url: "http://kcanari.egloos.com"
      }
      ret = Kotaim::BlogUtil.collect_info_with_url(@blogger_url)
      expect(ret).to eq(exp)
    end

    it 'collects good tags and images from post' do
      exp0 = ["일본여행", "벳부", "오이타", "큐슈", "규슈", "젤라또", "젤라토", "아이스크림"]
      exp1 = [
        "http://pds21.egloos.com/pds/201606/21/17/a0008417_5768bcfbd06eb.jpg",
        "http://pds21.egloos.com/pds/201606/21/17/a0008417_5768bcfc8c785.jpg",
        "http://pds25.egloos.com/pds/201606/21/17/a0008417_5768bcfcde1d3.jpg"
      ]
      xml = RestClient.get(@blogger_rss_url).body
      feed = Feedjira.parse(xml)

      ret = Kotaim::PostUtil.get_tags_and_images(feed.generator, feed.entries.first.url)

      expect(ret[0]).to eq(exp0)
      expect(ret[1].first(3)).to eq(exp1)
    end
  end
end
