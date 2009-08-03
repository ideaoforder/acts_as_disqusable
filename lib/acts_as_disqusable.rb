module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Disqusable #:nodoc:
      require 'disqus'
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        # Macro that adds theme for object
        def acts_as_disqusable(options = {})
          @@configuration = YAML::load(File.open("#{RAILS_ROOT}/config/disqus.yml"))
          @@configuration.update(options) if options.is_a?(Hash)
          include ActiveRecord::Acts::Disqusable::InstanceMethods
          
          after_create :create_thread

          def thread_column
            @@configuration[:thread_column] || 'thread_id'
          end

          def forum_id
            @@configuration[:forum_id].to_s || nil
          end
          
          def forum_api_key
            @@configuration[:forum_api_key] || nil
          end
          
          def threads
            Disqus::Forum.find(self.forum_id).threads
          end        
          
          def find_thread_by_url(url)
            Disqus::Forum.get_thread_by_url(url, self.forum_api_key)
          end
          
          def comment_count(ids={})
            if !ids.is_a? Hash
              c = "id IN (" + ids.join(',')+ ")"
            else
              c = nil
            end
            thread_ids = Post.all(:conditions => c, :select => :thread_id).collect(&:thread_id).compact.join(',')
            Disqus::Forum.posts_count(thread_ids, self.forum_api_key)
          end
          
        end
      end

      module InstanceMethods
        def thread
          Disqus::Thread.find_or_create(title, slug)
        end     
        
        def comments
          if self.respond_to? self.class.thread_column
            Disqus::Forum.posts(self.send(self.class.thread_column), self.class.forum_api_key)
          else # two separate calls
            Disqus::Thread.find_or_create(title, slug).posts
          end
        end
        
        def comment_count
          if self.respond_to? self.class.thread_column
            Disqus::Forum.posts_count(self.send(self.class.thread_column), self.class.forum_api_key)
          else # two separate calls
            Disqus::Thread.find_or_create(title, slug).posts_count
          end
        end
        
        private        
          def create_thread
            t = Disqus::Thread.find_or_create(title, slug)
            if self.respond_to? self.class.thread_column
              self.write_attribute(self.class.thread_column, t.id)
              self.save
            end
          end 
      end      
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Disqusable)
