# frozen_string_literal: true

RSpec.describe 'blogme' do
  include WebMock::API

  context 'when handling blogme blog' do
    before do
      @blogger_url = 'http://nau2001.blog.me'
      @blogger_rss_url = 'http://rss.blog.naver.com/nau2001.xml'

      blogme_rss_sample = File.open('spec/fixtures/blogme_rss_sample.xml').read
      stub_request(:get, "http://rss.blog.naver.com/nau2001.xml")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'rss.blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: blogme_rss_sample, headers: {})

      blogme_post_sample = File.open('spec/fixtures/blogme_post_sample.html').read
      stub_request(:get, "http://blog.naver.com/nau2001/222158658194")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: blogme_post_sample, headers: {})

      blogme_post_sample2 = File.open('spec/fixtures/blogme_post_sample2.html').read
      stub_request(:get, "https://m.blog.naver.com/PostView.nhn?blogId=nau2001&directAccess=fa"\
        "lse&logNo=222158658194&redirect=Dlog&widgetTypeCall=true")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'm.blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: blogme_post_sample2, headers: {})
    end

    it 'collects good blog information' do
      exp = {
        description: "여행은 일이자...취미\n먹는건 생활이자....행복\n신제품에 대한 관심은....본능\n▒이웃추가大환영▒\n▒서이추는친해지고해요▒",
        generator: "Naver Blog",
        image: "http://blogpfthumb.phinf.naver.net/MjAxODA4MDlfMTQ4/MDAxNTMzNzQ2NDQ2MzAw.2_c"\
          "7hGTYwAWgDp_H8WMWSDXVtK9iu_MEkFy2ZcqxfIkg.9WJuVHhJp-vvRcL5YBuhYLbQFN6FpuTMt-sSBhanU2og.JPEG.nau2001/IMG_1883.jpg?type=m2",
        rss_url: "http://rss.blog.naver.com/nau2001.xml",
        title: "와그잡의 트래블홀릭",
        url: "http://nau2001.blog.me"
      }
      ret = Kotaim::BlogUtil.collect_info_with_url(@blogger_url)
      expect(ret).to eq(exp)
    end

    it 'collects good tags and images from post' do
      exp0 = ["용산모니터", "lg27인치모니터", "lg모니터", "게이밍모니터", "용산게이밍모니터"]

      #   "https://blogpfthumb-phinf.pstatic.net/MjAxODA4MDlfMTQ4/MDAxNTMzNzQ2NDQ2MzAw.2_c7hGTYwAWgD"\
      #   "p_H8WMWSDXVtK9iu_MEkFy2ZcqxfIkg.9WJuVHhJp-vvRcL5YBuhYLbQFN6FpuTMt-sSBhanU2og.JPEG.nau2001/IMG_1883.jpg?type=s1",
      # "https://mblogthumb-phinf.pstatic.net/MjAyMDExMjhfMjYx/MDAxNjA2NDg5MjcxOTc4.GTjdu0p0_E2S6eG"\
      #   "tpZMYy1stUx5FMBbYmY_tRIhEy2Ig.8N3fai-EnMjZTPTIsjvZrqvPhhmWAJrFlxeLvGdcI5og.JPEG.nau2001/IMG_3931.jpg?type=w80_blur",
      # "https://mblogthumb-phinf.pstatic.net/MjAyMDExMjdfMTAg/MDAxNjA2NDg5MDkyMjM5.1Y_tnkKDl35tvua4"\
      #   "utgjKnMZqY-QBF3GHVIrh6uICaYg.wogv0m128SSc8F2D-X9PNK2zILE-sr9tPARbNm7Iv5og.JPEG.nau2001/IMG_3833.jpg?type=w80_blur"

      exp1 = [
        "https://blogpfthumb-phinf.pstatic.net/MjAxODA4MDlfMTQ4/MDAxNTMzNzQ2NDQ2MzAw.2_c7hGTYwAWgD"\
          "p_H8WMWSDXVtK9iu_MEkFy2ZcqxfIkg.9WJuVHhJp-vvRcL5YBuhYLbQFN6FpuTMt-sSBhanU2og.JPEG.nau2001/IMG_1883.jpg",
        "https://postfiles.pstatic.net/MjAyMDExMjhfMjYx/MDAxNjA2NDg5MjcxOTc4.GTjdu0p0_E2S6eG"\
          "tpZMYy1stUx5FMBbYmY_tRIhEy2Ig.8N3fai-EnMjZTPTIsjvZrqvPhhmWAJrFlxeLvGdcI5og.JPEG.nau2001/IMG_3931.jpg?type=w966",
        "https://postfiles.pstatic.net/MjAyMDExMjdfMTAg/MDAxNjA2NDg5MDkyMjM5.1Y_tnkKDl35tvua4"\
          "utgjKnMZqY-QBF3GHVIrh6uICaYg.wogv0m128SSc8F2D-X9PNK2zILE-sr9tPARbNm7Iv5og.JPEG.nau2001/IMG_3833.jpg?type=w966"
      ]
      xml = RestClient.get(@blogger_rss_url).body
      feed = Feedjira.parse(xml)

      ret = Kotaim::PostUtil.get_tags_and_images(feed.generator, feed.entries.first.url)
      expect(ret[0]).to eq(exp0)
      expect(ret[1].first(3)).to eq(exp1)
    end
  end
end
