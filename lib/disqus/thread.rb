module Disqus
  class Thread
    attr_accessor :id, :forum, :slug, :title, :created_at, :allow_comments, :url, :identifier, :hidden
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
    def posts
      response = self.class.get('/get_thread_posts', :query => { :thread_id => id })
      response["message"].map { |data| Disqus::Post.new(data) }
    end
    
    # Sets the provided values on the thread object.
    def update(opts = {})
      result = self.class.post('/update_thread', :query => opts.merge(:forum_api_key  => forum.key))
      return result["succeeded"]
    end
  end
end
