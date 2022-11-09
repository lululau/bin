#!/usr/bin/env ruby

require 'nokogiri'
require 'chinese_pinyin'

doc = Nokogiri::HTML(ARGF)

id_changes = doc.css('h1[id],h2[id],h3[id],h4[id],h5[id],h6[id]').map do |e, changes|
  id = e[:id]
  id_py = Pinyin.t(id, splitter: '_')
  e[:id] = id_py
  [id, id_py]
end.to_h

title_id_mapping = doc.css('a[href]').map do |e|
  href = e[:href]
  key = href[1..-1]
  if id_py = id_changes[key]
    e[:href] = "##{id_py}"
    [e.text, id_py]
  end
end.compact.to_h

doc.css('nav#sidebar a').each do |toc_link|
  text = toc_link.children.find { |n| n.type == 3 }
  next unless text
  key = text.content[1..-1]
  if new_id = title_id_mapping[key] || id_changes[key]
    toc_link[:href] = "##{new_id}"
  end
end

print doc.to_html
