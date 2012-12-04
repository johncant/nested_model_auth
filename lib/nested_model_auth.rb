require "nested_model_auth/version"

module NestedModelAuth

  class AuthorizationRule

    attr_accessor :auth_action, :block

    def initialize(auth_action, &block)
      @auth_action = auth_action
      @block = block
    end

    def invoke_for(model, resource)
      model.instance_exec(resource, &@block)
    end

  end

  module Model
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods

      base.send :cattr_accessor, :authorization_rules
      base.authorization_rules = {}
        puts base.inspect

      base.send :after_initialize do
        @authorizations = {}
      end
    end

    module InstanceMethods

      def allow_save_by?(resource)
        @authorizations[:save] ||= {}
        @authorizations[:save][resource[resource.class.primary_key]] ||= run_authorization_rules(resource)
      end

      def run_authorization_rules(resource)
        # To allow access, one :allow rule must return true, and NO deny rules must return true
        allow_access = false
        deny_access = false
        self.class.authorization_rules[:save].each do |rule|

          if rule.auth_action == :allow
            allow_access ||= rule.invoke_for(self, resource)
          end

          if rule.auth_action == :deny
            deny_access ||= rule.invoke_for(self, resource)
            break if deny_access
          end

        end

        if (allow_access && !deny_access)
          true
        else
          false
        end

      end

    end

    module ClassMethods

      def allow_save_by(&block)
        self.authorization_rules[:save] ||= []
        self.authorization_rules[:save] << AuthorizationRule.new(:allow, &block)
      end

      def deny_save_by(&block)
        self.authorization_rules[:save] ||= []
        self.authorization_rules[:save] << AuthorizationRule.new(:deny, &block)
      end

    end
  end
end

