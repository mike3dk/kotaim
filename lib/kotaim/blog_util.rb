# frozen_string_literal: true

require 'rest-client'
require 'feedjira'
require 'action_view'

module Kotaim
  module BlogUtil
    def self.collect_info_with_url(url)
      rss_url = guess_rss_url(url)
      collect_info(rss_url)
    end

    def self.collect_info(rss_url)
      puts format('>> rss_url: %s', rss_url)
      ::Feedjira::Feed.add_common_feed_element("generator")
      xml = RestClient.get(rss_url).body
      feed = Feedjira.parse(xml)

      puts format("$$$$ generator: %s $$$$", feed.generator)

      {
        title: feed.title,
        url: feed.url,
        rss_url: feed.feed_url,
        description: feed.description,
        generator: feed.generator
      }
    end

    def self.guess_rss_url(url)
      u = URI.parse(url)
      # http://blog.naver.com/ssamssam48
      # https://rss.blog.naver.com/ssamssam48.xml
      if u.host.include?('blog.naver.com')
        return format('http://rss.%s%s.xml', u.host, u.path)
      end

      if u.host.include?('daum.net')
        return format('http://blog.daum.net/xml/rss%s', u.path)
      end

      if u.host.include?('egloos.com')
        return format('http://rss.egloos.com/blog/%s', u.host.split('.').first)
      end

      format('http://%s/rss', u.host)
    end
  end
end
