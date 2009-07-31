#module ActiveRecord #:nodoc:
#  module Acts #:nodoc:
#    module Disqusable #:nodoc:
#      #require 'disqus/disqus'
#      
#      def self.included(base)
#        base.extend(ClassMethods)
#      end
#      
#      module ClassMethods
#        # Macro that adds theme for object
#        def acts_as_disqusable(options = {})
#          @@configuration = {}
#          @@configuration.update(options) if options.is_a?(Hash)
#          include ActiveRecord::Acts::Disqusable::InstanceMethods

#          def forum_id
#            @@configuration[:forum_id] || nil
#          end
#          
#          def forum_api_key
#            @@configuration[:forum_api_key] || nil
#          end
#        end
#      end

#      module InstanceMethods
#      
#      end      
#    end
#  end
#end

#ActiveRecord::Base.send(:include, ActiveRecord::Acts::Disqusable)
