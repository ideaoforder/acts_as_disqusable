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
          
          def title_column
            @@configuration[:title_column] || 'title'
          end
          
          def slug_column
            @@configuration[:slug_column] || 'slug'
          end
          
          def prefix
            if @@configuration[:prefix].nil?
              return self.to_s.downcase + '-'
            elsif @@configuration[:prefix]
              return @@configuration[:prefix] + '-'
            else
              return ''
            end
          end

          def forum_id
            @@configuration[:forum_id].to_s || nil
          end
          
          def forum_api_key
            @@configuration[:forum_api_key] || nil
          end
          
          def forum_shortname
            @@configuration[:forum_shortname] || nil
          end
          
          def threads
            Disqus::Forum.find(self.forum_id).threads
          end        
          
          def find_thread_by_url(url)
            Disqus::Forum.get_thread_by_url(url, self.forum_api_key)
          end
          
          def comment_count(ids={})
            if self.column_names.include? self.thread_column
              if !ids.is_a? Hash
                c = "id IN (" + ids.join(',')+ ")"
              else
                c = nil
              end
              thread_ids = Post.all(:conditions => c, :select => :thread_id).collect(&:thread_id).compact.join(',')
              if thread_ids.length > 0
                Disqus::Forum.posts_count(thread_ids, self.forum_api_key)
              else 
                Hash.new
              end
            else
              'This operation is not supported without a thread_column.'
            end
          end
          
          # limit — Number of entries that should be included in the response. Default is 25.
          # start — Starting point for the query. Default is 0.
          # filter — Type of entries that should be returned (new, spam or killed).
          # exclude — Type of entries that should be excluded from the response (new, spam or killed).
          def comments(opts={})
            Disqus::Forum.posts(self.forum_api_key, opts)
          end
          
          def comment_permalink(comment, opts={})
            title = comment.thread['title']
            if comment.thread['url']
              permalink = comment.thread['url']
            else
              url = comment.thread['identifier'].first.sub(self.prefix, '')
              path = opts[:path] || self.to_s.pluralize.downcase
              permalink = "/#{path}/#{url}"
            end
            return "<a href=\"#{permalink}\" class=\"#{opts[:class]}\" title=\"#{opts[:title]}\">#{title}</a>"
          end
        end
      end

      module InstanceMethods
        def thread_identifier
          self.class.prefix + self.send(self.class.slug_column)
        end
        
        def thread
          Disqus::Thread.find_or_create(self.send(self.class.title_column), self.thread_identifier)
        end     
        
        # limit — Number of entries that should be included in the response. Default is 25.
        # start — Starting point for the query. Default is 0.
        # filter — Type of entries that should be returned (new, spam or killed).
        # exclude — Type of entries that should be excluded from the response (new, spam or killed).
        def comments(opts={})
          if self.respond_to? self.class.thread_column and self.send(self.class.thread_column)
            Disqus::Thread.posts(self.send(self.class.thread_column), opts)
          else # two separate calls
            Disqus::Thread.find_or_create(title, slug).posts(opts)
          end
        end
        
        def comment_count
          if self.respond_to? self.class.thread_column and self.send(self.class.thread_column)
            Disqus::Forum.posts_count(self.send(self.class.thread_column), self.class.forum_api_key)
          else # two separate calls
            Disqus::Thread.find_or_create(title, slug).posts_count
          end
        end

        def comment_form
          forum_shortname = self.class.forum_shortname
          thread_indentifier = self.thread_identifier
          url = 'http://disqus.com/api/reply.js?' +
            "forum_shortname=#{forum_shortname}&" +
            "thread_identifier=#{thread_identifier}"
          s = '<div id="dsq-reply">'
          s << '<script type="text/javascript" src="%s"></script>' % url
          s << '</div>'
          return s
        end
        
        private        
          def create_thread
            t = Disqus::Thread.find_or_create(self.send(self.class.title_column), self.thread_identifier)
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
