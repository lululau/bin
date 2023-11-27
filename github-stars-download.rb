#!/usr/bin/env ruby

#######################################
#
#   github-stars-download.rb
#
#   pre-requisites:
#     - Ruby >= 2.0.0
#     - gem install octokit
#
#######################################

require 'octokit'
require 'fileutils'
require 'base64'

# Get the user's name
user = ARGV[0]

# If no user name give, print error message
if user.nil?
  puts "Please provide a username"
  exit
end

FileUtils.mkdir_p "github-stars/#{user}"
FileUtils.mkdir_p "github-stars/#{user}/repos"

github = Octokit::Client.new
github.auto_paginate = false

puts "Getting #{user}'s starred repos..."

page = github.starred(user)
last_response = github.last_response

File.open("github-stars/#{user}/repos.txt", "w") do |file|
  loop do
    page.each do |repo|
      # Get the repo name
      name = repo.name
      # Get the repo owner
      owner = repo.owner.login
      # Get the repo clone URL
      clone_url = repo.clone_url
      # Get the repo description
      description = repo.description

      puts "Getting #{owner}/#{name}..."

      # Print the repo name and owner
      file.puts "#{owner}/#{name} - #{description}"


      # Create a directory for the repo
      FileUtils.mkdir_p "github-stars/#{user}/repos/#{owner}/#{name}"

      # download readme
      begin
        readme = github.readme("#{owner}/#{name}")
        File.open("github-stars/#{user}/repos/#{owner}/#{name}/README.md", "w") do |f|
          f.write(Base64.decode64(readme.content))
        end
      rescue Octokit::NotFound
        STDERR.puts "No README found for #{owner}/#{name}"
      end
    end
    break if last_response.rels[:next].nil?
    page = github.get(last_response.rels[:next].href)
    last_response = github.last_response
  end
end
