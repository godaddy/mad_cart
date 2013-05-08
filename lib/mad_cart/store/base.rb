module MadCart
  module Store
    class SetupError < StandardError; end
    module Base

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          include(InheritableAttributes)
          inheritable_attributes :connection_delegate, :required_connection_args, :fetch_delegates, :format_delegates, :after_init_delegate
        end
      end

      def initialize(*args)
        set_init_args(*args)
        after_initialize(*args)
      end

      def connection
        validate_connection_args!
        @connection ||= execute_delegate(self.class.connection_delegate, @init_args)
        return @connection
      end

      def execute_delegate(delegate, *args)
        return delegate.call(*args) if delegate.is_a?(Proc)
        return self.send(delegate, *args) if delegate.is_a?(Symbol)

        raise ArgumentError, "Invalid delegate" # if not returned by now
      end
      private :execute_delegate

      def after_initialize(*args)
        return nil unless self.class.after_init_delegate
        execute_delegate(self.class.after_init_delegate, *args)
      end
      private :after_initialize

      def validate_connection_args!
        raise(SetupError, "It appears MyStore has overrided the default MadCart::Base initialize method. " +
                          "That's fine, but please store any required connection arguments as @init_args " +
                          "for the #connection method to use later. Remember to call #after_initialize " +
                          "in your initialize method should you require it.") if init_args_missing?

        raise(ArgumentError,"Missing connection arguments: " +
                            "#{(self.class.required_connection_args - @init_args.keys)
                            .join(', ')}") unless self.class.required_connection_args.all? {|req| @init_args.include?(req) }
      end
      private :validate_connection_args!

      def init_args_missing?
        !self.class.required_connection_args.empty? && @init_args.nil?
      end
      private :init_args_missing?

      def set_init_args(*args)
        @init_args ||= configured_connection_args.merge(args.last || {})
      end
      private :set_init_args

      def configured_connection_args
        MadCart.config.send(self.class.to_s.demodulize.underscore) || {}
      end
      private :configured_connection_args

      def ensure_model_format(model, results)
        results.first.is_a?(MadCart::Model::Base) ? results : map_to_madcart_model(model, results)
      end
      private :ensure_model_format

      def map_to_madcart_model(model, results)
        results.map {|args| "MadCart::Model::#{model.to_s.classify}".constantize.new(args) }
      end
      private :map_to_madcart_model

      module ClassMethods
        def create_connection_with(*args)
          @connection_delegate = parse_delegate(args.first)
          opts = args[1] || {}
          @required_connection_args = opts[:requires] || []

          raise ArgumentError, "Invalid delegate for create_connection_with: " +
                               "#{args.first.class}. Use Proc or Symbol. " if @connection_delegate.nil?
        end

        def fetch(model, options={})
          @fetch_delegates ||= {}
          @format_delegates ||= {}
          @fetch_delegates[model] = parse_delegate(options)

          raise ArgumentError, "Invalid delegate for fetch: #{options.first.class}. Use Proc or Symbol." if @fetch_delegates[model].nil?

          define_method model do
            fetch_result = execute_delegate(self.class.fetch_delegates[model])
            formatted_result = self.class.format_delegates[model] ? fetch_result.map{|r| execute_delegate(self.class.format_delegates[model], r)} : fetch_result

            return ensure_model_format(model, formatted_result)
          end
        end

        def format(model, options={})
          raise ArgumentError, "Cannot define 'format' for a model that has not defined 'fetch'" if @fetch_delegates[model].nil?

          @format_delegates[model] = parse_delegate(options)

          raise ArgumentError, "Invalid delegate for format: #{args.first.class}. Use Proc or Symbol." if @format_delegates[model].nil?
        end

        def after_initialize(*args)
          @after_init_delegate = parse_delegate(args.first)

          raise ArgumentError, "Invalid delegate for after_initialize: #{args.first.class}. Use Proc or Symbol." if @after_init_delegate.nil?
        end

        def parse_delegate(arg)
          return arg if (arg.is_a?(Symbol) || arg.is_a?(Proc))
          return arg[:with] if arg.is_a?(Hash) && arg[:with]

          return nil # if no match
        end
        private :parse_delegate

      end
    end
  end
end
