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
        []
      end
    end

    def self.get_tags_and_images_from_egloos(url)
      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      ret_tag = doc.css("div#section_content a[rel='tag']").map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ret_img = doc.css('div#section_content img').map do |e|
        e['src']
      end

      [ret_tag, ret_img]
    end

    def self.get_tags_and_images_from_tistory(url)
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
      url = handle_blogme(url)

      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      u = URI.parse(url)
      u3 = doc.css('iframe#mainFrame').attribute('src').value
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

      ret_img = manual_cleanup(ret_img)

      [ret_tag, ret_img]
    end

    def self.manual_cleanup(images)
      images.map do |img|
        if img.include?("type=w80_blur")
          img.gsub!("mblogthumb-phinf.pstatic.net", "postfiles.pstatic.net")
          img.gsub!("type=w80_blur", "type=w966")
        elsif img.include?("type=s1")
          img.gsub!("?type=s1", "")
        end
      end
    end

    def self.get_tags_and_images_from_daum(url)
      # resp = RestClient.get(url)
      # doc = Nokogiri::HTML(resp.body)

      # u = URI.parse(url)
      # u3 = doc.css('iframe').attribute('src').value
      # u4 = format('http:%s', u3)
      # resp = RestClient.get(u4)
      # doc = Nokogiri::HTML(resp.body)

      # ret_tag = doc.css('div.tagList a').map do |e|
      #   t = ActionView::Base.full_sanitizer.sanitize(e.text)
      #   sanitize(t)
      # end

      ###
      url = convert_to_mobile_url(url)
      resp = RestClient.get(url)
      doc = Nokogiri::HTML(resp.body)

      ret_tag = doc.css('div.list_tag a.link_tag').map do |e|
        t = ActionView::Base.full_sanitizer.sanitize(e.text)
        sanitize(t)
      end

      ret_img = doc.css('div.blogview_content img').map do |e|
        e['src'].gsub('R400x0', 'image')
      end

      [ret_tag, ret_img]
    end

    def self.handle_blogme(url)
      return url if url.include?('naver.com')

      # http://nau2001.blog.me/222158658194
      # http://blog.naver.com/nau2001/222158658194
      if url.include?('blog.me')  # rubocop:disable Style/GuardClause
        u = URI.parse(url)

        user = u.host.split('.').first
        post_id = u.path

        format('http://blog.naver.com/%s%s', user, post_id)
      end
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
