module MadCart
  module Store
    class SetupError < StandardError
      def self.message
        "It appears MyStore has overrided the default "\
        "MadCart::Base initialize method. That's fine, but please store "\
        "any required connection arguments as @init_args for the "\
        "#connection method to use later. Remember to call #after_initialize "\
        "in your initialize method should you require it."
      end
    end

    InvalidStore       = Class.new(StandardError)
    ServerError        = Class.new(StandardError)
    InvalidCredentials = Class.new(StandardError)

    module Base
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          include InheritableAttributes
          inheritable_attributes :connection_delegate, :required_connection_args,
            :fetch_delegates, :format_delegates, :after_init_delegate
        end
      end

      def initialize(*args)
        set_init_args(*args)
        after_initialize(*args)
      end

      def connection
        validate_connection_args!
        return init_connection
      end

      def init_connection
        @connection ||= execute_delegate(klass.connection_delegate, @init_args)
      end

      def klass
        self.class
      end
      private :klass

      def execute_delegate(delegate, *args)
        return self.send(delegate, *args) if delegate.is_a?(Symbol)
        return delegate.call(*args) if delegate.is_a?(Proc)

        raise ArgumentError, "Invalid delegate" # if not returned by now
      end
      private :execute_delegate

      def after_initialize(*args)
        return nil unless klass.after_init_delegate
        execute_delegate(klass.after_init_delegate, *args)
      end
      private :after_initialize

      def validate_connection_args!
        return true if klass.required_connection_args.empty?

        raise(SetupError, SetupError.message) if @init_args.nil?
        raise(ArgumentError,"Missing connection arguments: "\
              "#{missing_args.join(', ')}") if missing_args.present?
      end
      private :validate_connection_args!

      def missing_args
        klass.required_connection_args - @init_args.keys
      end
      private :missing_args

      def set_init_args(*args)
        @init_args ||= configured_connection_args.merge(args.last || {})
      end
      private :set_init_args

      def configured_connection_args
        MadCart.config.send(klass.to_s.demodulize.underscore) || {}
      end
      private :configured_connection_args

      def ensure_model_format(model, results)
        if results.first.is_a?(MadCart::Model::Base)
          results
        else
          map_to_madcart_model(model, results)
        end
      end
      private :ensure_model_format

      def map_to_madcart_model(model, results)
        results.map do |args|
          "MadCart::Model::#{model.to_s.classify}".constantize.new(args)
        end
      end
      private :map_to_madcart_model

      module ClassMethods
        def create_connection_with(*args)
          @connection_delegate = parse_delegate(args.first, :create_connection_with)
          opts = args[1] || {}
          @required_connection_args = opts[:requires] || []
        end

        def fetch(model, options={})
          @fetch_delegates ||= {}
          @format_delegates ||= {}
          @fetch_delegates[model] = parse_delegate(options, :fetch)

          define_method_for(model)
        end

        def format(model, options={})
          if @fetch_delegates[model].nil?
            raise ArgumentError, "Cannot define 'format' for a model that has not defined 'fetch'"
          end

          @format_delegates[model] = parse_delegate(options, :format)
        end

        def after_initialize(*args)
          @after_init_delegate = parse_delegate(args.first, :after_initialize)
        end

        def parse_delegate(arg, method)
          return arg if (arg.is_a?(Symbol) || arg.is_a?(Proc))
          return arg[:with] if arg.is_a?(Hash) && arg[:with]

          raise ArgumentError, "Invalid delegate for #{method}: "\
            "#{arg.first.class}. Use Proc or Symbol. "
        end
        private :parse_delegate

        def define_method_for(model)
          define_method model do |*args|
            fetch_result = execute_delegate(self.class.fetch_delegates[model], *args)
            formatted_result = if self.class.format_delegates[model]
                                 formatter = self.class.format_delegates[model]
                                 fetch_result.map{|r| execute_delegate(formatter, r)}
                               else
                                 fetch_result
                               end

            return ensure_model_format(model, formatted_result)
          end
        end
        private :define_method_for

      end
    end
  end
end
