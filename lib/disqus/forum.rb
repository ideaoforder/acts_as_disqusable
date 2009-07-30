module Disqus
  class Forum
    attr_accessor :id, :shortname, :name, :created_at
    def initialize(data)
      data.each { |k, v| send(:"#{k}=", v) }
    end
    
    def self.all
      @@all ||= begin
        response = self.class.get('/get_forum_list')
        response["succeeded"] ? response["message"].map { |data| Disqus::Forum.new(data) } : nil
      end
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
    def threads
      response = self.class.get('/get_thread_list', :query => { 
        :forum_api_key => key, 
        :forum_id => forum_id 
      })
      response["succeeded"] ? response["message"].map { |data| Disqus::Thread.new(data) } : nil
    end
    
    # Returns a thread associated with the given URL.
    #
    # A thread will only have an associated URL if it was automatically
    # created by Disqus javascript embedded on that page.
    def get_thread_by_url(url)
      response = self.class.get('/get_thread_by_url', :query => { :url => url, :forum_api_key => key })
      response["succeeded"] ? Thread.new(response["message"]) : nil
    end

    def thread_by_identifier(identifier, title)
      response = self.class.post('/thread_by_identifier', :query => { 
        :forum_api_key => key,
        :identifier => identifier,
        :title => title 
      })
      
      response["succeeded"] ? Thread.new(response["message"]["thread"]) : nil
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
    def update_thread(thread_id, opts = {})
      response = self.class.post('/update_thread', :query => opts.merge(:forum_api_key  => key)
      response["succeeded"]
    end
  end
end
