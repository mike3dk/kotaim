# Kotaim

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/kotaim`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Add this line to your application's Gemfile:

```
gem 'kotaim'
```

And then execute:

```
$ bundle
```

Or install it yourself as:
```
$ gem install kotaim
```

## Usage

### BlogUtil.collect_info_with_url
```
blog_url = https://blog.naver.com/user
info = Kotaim::BlogUtil.collect_info_with_url(blog_url)
puts info
info = {
    title: 'my blog',
    url: 'https://blog.naver.com/user',
    rss_url: 'https://rss.blog.naver.com/user.xml',
    image: 'https://blogfthumb.phinf.naver.net/myimage.jpg',
    description: 'my blog',
    generator: 'Naver Blog'
}
```

### PostUtil.get_tags_and_images(generator, url)
```
generator = 'Naver Blog'
url = 'https://blog.naver.com/user/1000
tags, images = Kotaim::PostUtil.get_tags_and_images(generator, url)
puts tags, images
# tags = ["tag1", "tag2", "tag3"]
# images = ["https://example.com/image1.jpg", "https://example.com/image2.jpg]
```
