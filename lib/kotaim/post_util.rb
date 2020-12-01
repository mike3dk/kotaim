# frozen_string_literal: true

module Kotaim
  module PostUtil
    def self.get_tags_and_images(blog_platform, url)
      case blog_platform
      when 'Naver Blog'
        get_tags_and_images_from_naver(url)
      when 'TISTORY'
        get_tags_and_images_from_tistory(url)
      when 'Daum Blog (http://blog.daum.net/)'
        get_tags_and_images_from_daum(url)
      when 'Egloos'
        get_tags_and_images_from_egloos(url)
      else
        puts 'NO PARSER'
        []
      end
    end

    def self.get_tags_and_images_from_egloos(url)
      puts format('<<< get_tags_and_images_from_egloos(%s) >>>', url)
      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      ret_tag = doc.css("a[rel='tag']").map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ret_img = doc.css('div#section_content img').map do |e|
        e['src']
      end

      [ret_tag, ret_img]
    end

    def self.get_tags_and_images_from_tistory(url)
      puts format('<<< get_tags_and_images_from_tistory(%s) >>>', url)
      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      ret_tag = doc.css("a[rel='tag']").map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ret_img = doc.css('div.article img').map do |e|
        e['src']
      end

      [ret_tag, ret_img]
    end

    def self.get_tags_and_images_from_naver(url)
      puts format('<<< get_tags_and_images_from_naver(%s) >>>', url)
      url = handle_blogme(url)

      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      u = URI.parse(url)
      u3 = doc.css('frame#mainFrame').attribute('src').value
      u4 = format('https://m.%s%s', u.host, u3)
      resp = RestClient.get(u4)
      doc = Nokogiri::HTML(resp.body)

      tags = doc.css('div.post_tag').css('span')
      ret_tag = tags.map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ret_img = doc.css('div.post_ct img').map do |e|
        e['src']
      end

      doc.css('span._img').map do |e|
        found = format('%s%s', e['thumburl'], 'w2')
        ret_img << found
      end

      ret_img.uniq!
      ret_img.delete_if {|e| e.include?('blank.gif') }

      [ret_tag, ret_img]
    end

    def self.get_tags_and_images_from_daum(url)
      puts format('<<< get_tags_and_images_from_daum(%s) >>>', url)

      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      u = URI.parse(url)
      u3 = doc.css('frame').attribute('src').value
      u4 = format('http://%s%s', u.host, u3)
      resp = RestClient.get(u4)
      doc = Nokogiri::HTML(resp.body)

      ret_tag = doc.css('div.tagList a').map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ###

      url = convert_to_mobile_url(url)
      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      ret_img = doc.css('div#article img').map do |e|
        e['src'].gsub('R400x0', 'image')
      end

      [ret_tag, ret_img]
    end

    def self.handle_blogme(url)
      return url if url.include?('naver.com')

      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)
      doc.css('frame#screenFrame').attribute('src').value
    end

    def self.sanitize(text)
      text.delete('#,')
    end

    def self.convert_to_mobile_url(url)
      u = URI.parse(url)
      format('http://m.%s%s', u.host, u.path)
    end
  end
end
