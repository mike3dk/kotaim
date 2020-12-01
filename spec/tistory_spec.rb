# frozen_string_literal: true

RSpec.describe 'tistory' do
  include WebMock::API

  context 'when handling tistory blog' do
    before do
      @blogger_url = 'http://chakeun.tistory.com/'
      @blogger_rss_url = 'http://chakeun.tistory.com/rss'

      tistory_rss_sample = File.open('spec/fixtures/tistory_rss_sample.xml').read
      stub_request(:get, "http://chakeun.tistory.com/rss")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'chakeun.tistory.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: tistory_rss_sample, headers: {})

      tistory_post_sample = File.open('spec/fixtures/tistory_post_sample.html').read
      stub_request(:get, "https://chakeun.tistory.com/1060")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'chakeun.tistory.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: tistory_post_sample, headers: {})
    end

    it 'collects good blog information' do
      exp = {
        description: "미국서부여행과 LA생활의 이야기들",
        generator: "TISTORY",
        rss_url: @blogger_rss_url,
        image: nil,
        title: "위기주부의 미국서부여행과 LA생활",
        url: "https://chakeun.tistory.com/"
      }
      ret = Kotaim::BlogUtil.collect_info_with_url(@blogger_url)
      expect(ret).to eq(exp)
    end

    it 'collects good tags and images from post' do
      exp0 = ["국립공원", "데블스콜프코스", "데스밸리", "미국여행", "배드워터", "소금밭", "솔트플랫", "추수감사절", "캘리포니아", "퍼니스크릭"]
      exp1 = ["https://blog.kakaocdn.net/dn/bBRNEQ/btqOvSfNJfW/6hTYrJRjAPKDZIvA8SHlAK/img.jpg",
              "https://blog.kakaocdn.net/dn/IN1v0/btqOuIrabHD/7tJM5HVoQYOOBiXE13FCJK/img.jpg",
              "https://blog.kakaocdn.net/dn/Wc8y4/btqOxsnDEl6/xAAk8qk0r2AMMIaHrAjCk1/img.jpg"]
      xml = RestClient.get(@blogger_rss_url).body
      feed = Feedjira.parse(xml)

      ret = Kotaim::PostUtil.get_tags_and_images(feed.generator, feed.entries.first.url)
      expect(ret[0]).to eq(exp0)
      expect(ret[1].first(3)).to eq(exp1)
    end
  end
end
