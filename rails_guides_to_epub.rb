#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'eeepub'

DOC_TITLE = 'Ruby on Rails Guides'

def get_pages(src_dir)
  index_file = File.join(src_dir, 'index.html') 
  section = nil
  pages = [{ :section => section, :title => DOC_TITLE, :path => index_file }]
  
  Nokogiri::HTML(open(index_file)).css("#mainCol > *").each do |elm|
    if elm.name == 'h3'
      section = elm.content
    elsif elm.name == 'dl'
      links = elm.search('dt a')
      links.each do |link|
        pages << {
          :section => section,
          :title => link.content,
          :path => File.join(src_dir, link.attr('href'))
        }
      end
    end
  end
  
  pages
end

def get_images(src_dir)
  images = []
  
  Dir.glob(File.join(src_dir, 'images', '**/*.{png,gif}')).each do |path|
    flag = false
    tokens = path.split(File::SEPARATOR).find_all do |token|
      flag = true if token == 'images'
      flag && ! token.match(/.+\.(png|gif)$/)
    end
    
    images << { :path => path, :dir => tokens.join(File::SEPARATOR)}
  end
  
  images
end

def get_styles(src_dir)
  Dir.glob(File.join(src_dir, 'stylesheets', '*')).map do |path|
    { :path => path, :dir => 'stylesheets'}
  end
end

def get_creators(src_dir)
  credits_file = File.join(src_dir, 'credits.html')
  
  Nokogiri::HTML(open(credits_file)).css("h3").find_all { |elm|
    ! elm.attr('class')
  }.map { |elm| elm.content }
end

def get_nav(pages)
  section = nil, sec_num = 0, chap_num = 0
  pages.inject([]) do |nav, page|
    content = File.basename(page[:path])
    
    if page[:section].nil?
      nav << { :label => page[:title], :content => content }
    elsif section != page[:section]
      sec_num += 1
      chap_num = 1
      nav << {
        :label => "#{sec_num}. #{page[:section]}",
        :content => content,
        :nav => [{
          :label => "#{sec_num}-#{chap_num}. #{page[:title]}",
          :content => content
        }]
      }  
      section = page[:section]
    else
      chap_num += 1
      nav.last[:nav] << {
        :label => "#{sec_num}-#{chap_num}. #{page[:title]}",
        :content => content
      } unless nav.empty?
    end
    
    nav
  end
end

  src_dir = ARGV[0]
  
  pages = get_pages(src_dir)
  images = get_images(src_dir)
  styles = get_styles(src_dir)
  creators = get_creators(src_dir)

  
  epub = EeePub.make do
    title       DOC_TITLE
    creator     creators.join(', ')
    publisher   'Rails Documentation Team'
    date        Time.now.strftime('%Y-%m-%d')
    identifier  'http://guides.rails.info/', :scheme => 'URL'
    uid         'http://guides.rails.info/'
  
    # files pages + images + styles
    fs = pages.map {|p| p[:path]} + images.map {|i| {i[:path] => i[:dir]}} + styles.map {|s| {s[:path] => s[:dir]}}
    files fs
    nav get_nav(pages)
  end
  
  epub.save('RubyOnRailsGuides.epub')
