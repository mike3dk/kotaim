# frozen_string_literal: true

RSpec.xdescribe 'daum' do
  include WebMock::API

  context 'when handling daum blog' do
    before do
      @blogger_url = 'http://blog.daum.net/yoji88'
      @blogger_rss_url = 'http://blog.daum.net/xml/rss/yoji88'

      daum_rss_sample = File.open('spec/fixtures/daum_rss_sample.xml').read
      stub_request(:get, "http://blog.daum.net/xml/rss/yoji88")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'blog.daum.net',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: daum_rss_sample, headers: {})

      daum_post_sample = File.open('spec/fixtures/daum_post_sample.html').read
      stub_request(:get, "http://blog.daum.net/yoji88/2850")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'blog.daum.net',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: daum_post_sample, headers: {})

      stub_request(:get, "http://blog.daum.net//blog.daum.net/yoji88/api")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'blog.daum.net',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: "", headers: {})

      daum_post_sample2 = File.open('spec/fixtures/daum_post_sample2.html').read
      stub_request(:get, "http://m.blog.daum.net/yoji88/2850")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'm.blog.daum.net',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: daum_post_sample2, headers: {})
    end

    it 'collects good blog information' do
      exp = {
        description: "중국 사람과 자연의 참 모습을 바르게 보여드립니다.\n\n",
        generator: "Daum Blog (http://blog.daum.net/)",
        rss_url: nil,
        title: "콩지의 중국여행기",
        url: "http://blog.daum.net/yoji88"
      }
      ret = Kotaim::BlogUtil.collect_info_with_url(@blogger_url)
      expect(ret).to eq(exp)
    end

    it 'collects good tags and images from post' do
      exp0 = []
      exp1 = []
      xml = RestClient.get(@blogger_rss_url).body
      feed = Feedjira.parse(xml)

      ret = Kotaim::PostUtil.get_tags_and_images(feed.generator, feed.entries.first.url)
      expect(ret[0]).to eq(exp0)
      expect(ret[1].first(3)).to eq(exp1)
    end
  end
end
