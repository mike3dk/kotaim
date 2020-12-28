# frozen_string_literal: true

RSpec.describe 'naver' do
  include WebMock::API

  context 'when handling naver blog' do
    before do
      @blogger_url = 'http://blog.naver.com/ssamssam48'
      @blogger_rss_url = 'http://rss.blog.naver.com/ssamssam48.xml'

      naver_rss_sample = File.open('spec/fixtures/naver_rss_sample.xml').read
      stub_request(:get, "http://rss.blog.naver.com/ssamssam48.xml")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'rss.blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: naver_rss_sample, headers: {})

      naver_post_sample = File.open('spec/fixtures/naver_post_sample.html').read
      stub_request(:get, "http://blog.naver.com/ssamssam48/222070461955")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: naver_post_sample, headers: {})

      naver_post_sample2 = File.open('spec/fixtures/naver_post_sample2.html').read
      stub_request(:get, "https://m.blog.naver.com/PostView.nhn?blogId=ssamssam48&directAccess=false&"\
        "logNo=222070461955&redirect=Dlog&widgetTypeCall=true")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Host' => 'm.blog.naver.com',
            'User-Agent' => 'rest-client/2.1.0 (darwin19.6.0 x86_64) ruby/2.7.2p137'
          }
        )
        .to_return(status: 200, body: naver_post_sample2, headers: {})
    end

    it 'collects good blog information' do
      exp = {
        title: "용의주도미스고의 행복만들기♪",
        url: "http://blog.naver.com/ssamssam48",
        rss_url: @blogger_rss_url,
        description: "네이버 여행+ 제주에디터\n반려견과 제주살이\n올드잉글리쉬쉽독 여름치치\n여행은 내 삶의 樂",
        generator: "Naver Blog",
        image: "http://blogpfthumb.phinf.naver.net/20141208_167/ssamssam48_1417966160918tHsvF_JPEG/1234.jpg?type=m2"
      }
      ret = Kotaim::BlogUtil.collect_info_with_url(@blogger_url)
      expect(ret).to eq(exp)
    end

    it 'collects good tags and images from post' do
      exp0 = ["EOS850D", "dslr", "dslr카메라", "캐논"]

      # "https://mblogthumb-phinf.pstatic.net/MjAyMDA4MjFfMjYz/MDAxNTk3OTk1OTEzMDA5.H9Mt1P-qTYRU1PgE_ehjsfKHyfaZ"\
      #   "Kslut1VDq5MC024g.CKyZNE_LxD22U_Xlf_vSzjtvnI140vT2759MWbTTESwg.JPEG.ssamssam48/캡처.JPG?type=w80_blur",
      # "https://mblogthumb-phinf.pstatic.net/MjAyMDA4MjFfMTg5/MDAxNTk3OTk2MDg2MjEw.nMwnJwwor9Nue24E8WF28VYcrSGNc"\
      #   "o4CABOFSQy1TRgg.Cjvj782HwIxDrveHgLnygJflxS9okvQKxeshWe-6kXEg.JPEG.ssamssam48/20200820-IMG_5196.jpg?type=w80_blur",
      exp1 = [
        "https://blogpfthumb-phinf.pstatic.net/20141208_167/ssamssam48_1417966160918tHsvF_JPEG/1234.jpg",
        "https://postfiles.pstatic.net/MjAyMDA4MjFfMjYz/MDAxNTk3OTk1OTEzMDA5.H9Mt1P-qTYRU1PgE_ehjsfKHyfaZ"\
          "Kslut1VDq5MC024g.CKyZNE_LxD22U_Xlf_vSzjtvnI140vT2759MWbTTESwg.JPEG.ssamssam48/캡처.JPG?type=w966",
        "https://postfiles.pstatic.net/MjAyMDA4MjFfMTg5/MDAxNTk3OTk2MDg2MjEw.nMwnJwwor9Nue24E8WF28VYcrSGNc"\
          "o4CABOFSQy1TRgg.Cjvj782HwIxDrveHgLnygJflxS9okvQKxeshWe-6kXEg.JPEG.ssamssam48/20200820-IMG_5196.jpg?type=w966"
      ]

      xml = RestClient.get(@blogger_rss_url).body
      feed = Feedjira.parse(xml)

      ret = Kotaim::PostUtil.get_tags_and_images(feed.generator, feed.entries.first.url)
      expect(ret[0]).to eq(exp0)
      expect(ret[1].first(3)).to eq(exp1)
    end
  end
end
