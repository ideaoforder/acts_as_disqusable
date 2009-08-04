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
 
require 'acts_as_disqusable/forum'
require 'acts_as_disqusable/thread'
require 'acts_as_disqusable/post'
require 'acts_as_disqusable/author'
 
module Disqus
  @defaults = {
    :api_key => "",
    :account => "",
    :developer => false,
    :container_id => 'disqus_thread',
    :avatar_size => 48,
    :color => "grey",
    :default_tab => "popular",
    :hide_avatars => false,
    :hide_mods => true,
    :num_items => 15,
    :show_powered_by => true,
    :orientation => "horizontal",
    :forum_api_key => '', # optional--if you're just mapping one forum to your app, this is convenient
    :forum_id => '' # ditto
  }
 
  def self.defaults
    @config = @defaults.merge(YAML::load(File.open("#{RAILS_ROOT}/config/disqus.yml")))
  end
  
  # Widget to includes a comment form suitable for use with the Disqus
  # API. This is different from the other widgets in that you can specify
  # the thread identifier being commented on.
  def self.comment_form(forum_shortname, thread_identifier)
    url = 'http://disqus.com/api/reply.js?' +
      "forum_shortname=#{URI::encode(forum_shortname, /[^a-z0-9]/i)}&" +
      "thread_identifier=#{URI::encode(thread_identifier, /[^a-z0-9]/i)}"
    s = '<div id="dsq-reply">'
    s << '<script type="text/javascript" src="%s"></script>' % url
    s << '</div>'
    return s
  end
  
  [Author, Forum, Post, Thread].each do |klass|
    klass.class_eval "include HTTParty"
    klass.class_eval "base_uri 'http://disqus.com/api'"
    klass.class_eval "format :json"
    klass.class_eval "default_params :user_api_key => '#{self.defaults[:api_key]}'"
    klass.class_eval "default_params :forum_api_key => '#{self.defaults[:forum_api_key]}'"
    klass.class_eval "default_params :forum_id => '#{self.defaults[:forum_id]}'"
  end
end