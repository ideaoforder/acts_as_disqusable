module Disqus
  class Thread
    attr_accessor :id, :forum, :slug, :title, :created_at, :allow_comments, :url, :identifier, :hidden, :category
    def initialize(data)
      data.each { |k, v| send(:"#{k}=", v) }
    end
    
    def self.find_or_create(title, identifier)
      response = self.post('/thread_by_identifier', :body => { :title => title, :identifier => identifier }.merge(self.default_params))
      Disqus::Thread.new(response["message"]["thread"])
    end
    
    def posts_count
      response = self.class.get('/get_num_posts', :query => { :thread_ids => id })
      response["message"][id].first.to_i
    end

    # Returns an array of posts belonging to this thread.
    # limit — Number of entries that should be included in the response. Default is 25.
    # start — Starting point for the query. Default is 0.
    # filter — Type of entries that should be returned (new, spam or killed).
    # exclude — Type of entries that should be excluded from the response (new, spam or killed).    
    def self.posts(thread_id, opts={:exclude => 'spam'})
      response = self.get('/get_thread_posts', :query => opts.merge(:thread_id => thread_id ))
      response["message"].map { |data| Disqus::Post.new(data) }
    end
    
    def posts(opts={:exclude => 'spam'})
      self.class.posts(self.id)
    end
    
    # Sets the provided values on the thread object.
    def update(opts = {})
      result = self.class.post('/update_thread', :query => opts.merge(:forum_api_key  => forum.key))
      return result["succeeded"]
    end
  end
end
