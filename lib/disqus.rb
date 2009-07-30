# == From the {Disqus Website}[http://disqus.com]:

# "Disqus, pronounced "discuss", is a service and tool for web comments and
# discussions. The Disqus comment system can be plugged into any website, blog,
# or application. Disqus makes commenting easier and more interactive, while
# connecting websites and commenters across a thriving discussion community."
# 
# "Disqus is a free service to the general public with absolutely no inline
# advertisements."

# The Disqus gem helps you quickly and easily integrate Disqus's Javascript
# widgets into your Ruby-based website. Adding Disqus to your site literally
# takes only a few minutes. The Disqus gem also provides a complete
# implementation of the Disqus API for more complex applications.

# To use this code, please first create an account on Disqus[http://disqus.com].
require 'rubygems'
require 'httparty'

require 'disqus/forum'
require 'disqus/thread'
require 'disqus/post'

module Disqus
  def api_key=(new_key)
    @api_key = new_key
    [Author, Forum, Post, Thread].each do |klass|
      klass.include HTTParty
      klass.base_uri 'http://disqus.com/api'
      klass.format :json
      klass.default_params :user_api_key => @api_key
    end
  end
end