module Disqus
  class Post
    attr_accessor :id, :forum, :thread, :created_at, :message, :parent_post, :shown, :is_anonymous, :anonymous_author, :author, :points
    def initialize(data)
      data.each { |k, v| send(:"#{k}=", v) }
    end
    
    def author_name
      if is_anonymous
        anonymous_author["name"]
      else
        author["display_name"] || author["username"]
      end
    end
    
    def self.create(opts={})
      response = self.class.post('/create_post', :query => opts)
      if response["success"]
        Disqus::Post.new(response["message"])
      else
        nil
      end
    end
  end
end


