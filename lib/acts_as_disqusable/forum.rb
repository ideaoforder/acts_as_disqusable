module Disqus
  class Forum
    
    attr_accessor :id, :shortname, :name, :created_at, :description
    def initialize(data)
      data.each { |k, v| send(:"#{k}=", v) }
    end
    
    def self.all
      @@all ||= begin
        response = get('/get_forum_list')
        response["succeeded"] ? response["message"].map { |data| Disqus::Forum.new(data) } : nil
      end
    end
    
    def self.find(id)
      id = id.to_s if !id.is_a? String
      grouped = self.all.group_by(&:id)
      grouped[id].first if grouped[id]
    end
    
    # Returns the forum API Key for this forum.
    def key(user_api_key = nil)
      @key ||= begin
        response = self.class.get('/get_forum_api_key', :query => {
          :api_key => user_api_key,
          :forum_id => id 
        })
        response["succeeded"] ? response["message"] : nil
      end
    end
    
    # Returns an array of threads belonging to this forum.
    def self.threads(id, key)
      response = self.get('/get_thread_list', :query => { 
        :forum_api_key => key, 
        :forum_id => id 
      })
      response["succeeded"] ? response["message"].map { |data| Disqus::Thread.new(data) } : nil
    end
    
    def threads
      self.class.threads(self.id, self.key)
    end
    
    # Returns a thread associated with the given URL.
    #
    # A thread will only have an associated URL if it was automatically
    # created by Disqus javascript embedded on that page.
    def self.get_thread_by_url(url, key)
      response = self.get('/get_thread_by_url', :query => { :url => url, :forum_api_key => key })
      response["succeeded"] ? Thread.new(response["message"]) : nil
    end
    
    def get_thread_by_url(url)
      self.class.get_thread_by_url(url, self.key)
    end

    def self.thread_by_identifier(identifier, title, key)
      response = self.post('/thread_by_identifier', :query => { 
        :forum_api_key => key,
        :identifier => identifier,
        :title => title 
      })
      
      response["succeeded"] ? Thread.new(response["message"]["thread"]) : nil
    end
    
     def thread_by_identifier(identifier, title)
       self.class.thread_by_identifier(identifier, title, self.key)
     end
    
    # Sets the provided values on the thread object.
    #
    # Returns an empty success message.
    #
    # Options:
    #
    # * <tt>:title</tt> - the title of the thread
    # * <tt>:slug</tt> - the per-forum-unique string used for identifying this thread in disqus.com URL's relating to this thread. Composed of underscore-separated alphanumeric strings.
    # * <tt>:url</tt> - the URL this thread is on, if known.
    # * <tt>:allow_comment</tt> - whether this thread is open to new comments
    def self.update_thread(thread_id, key, opts = {})
      response = self.post('/update_thread', :query => opts.merge(:forum_api_key  => key))
      response["succeeded"]
    end
    
    def update_thread(thread_id, opts = {})
      self.class.update_thread(thread_id, self.key, opts = {})
    end
    
    def self.posts_count(thread_ids, key)
      response = self.get('/get_num_posts', :query => { :thread_ids => thread_ids, :forum_api_key  => key })
      out = Hash.new
      response["message"].each { |id, data| out[id] = data.first }
      if out.length == 1
        return out.values.first
      else
        return out
      end
    end
    
    def posts_count(thread_ids)
      self.class.posts_count(thread_ids, self.key)
    end

    # Returns an array of posts belonging to this thread.
    def self.posts(key, opts={:exclude => 'spam'})
      response = self.get('/get_forum_posts', :query => opts.merge(:forum_api_key  => key ))
      out = Hash.new
      response["message"].map { |data| Disqus::Post.new(data) }
    end
    
    def posts(opts={:exclude => 'spam'})
      self.class.posts(self.key)
    end
  end
end
