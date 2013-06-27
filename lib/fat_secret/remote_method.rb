module FatSecret
  module RemoteMethod
    def self.included(mod)
      super
      mod.send(:extend,ClassMethods)
    end

    module ClassMethods
      def remote(name,&b)
        obj = MethodObj.new(:name => name, :parent => self)
        b[obj]
        obj.run!
      end
    end

    class MethodObj
      include FromHash
      attr_accessor :name, :parent

      def method(*args)
        if args.empty?
          @method
        else
          @method = args.first
        end
      end

      def request_args(&b)
        if block_given?
          @request_args = b
        else
          @request_args
        end
      end

      def process(&b)
        if block_given?
          @process = b
        else
          @process
        end
      end

      def cache(*args)
        if args.empty?
          @cache
        else
          @cache = args.first
        end
      end

      def run!
        this = self

        parent.send(:define_method,"#{name}_obj") do |*args|
          args = instance_exec(*args,&this.request_args) if this.request_args

          if this.cache
            args << {} unless args.last.kind_of?(Hash)
            args.last[:cache] = true
          end

          request_obj(:get,this.method,*args)
        end

        parent.send(:define_method,"#{name}_raw") do |*args|
          send("#{this.name}_obj",*args).results
        end

        parent.send(:define_method,name) do |*args|
          res = send("#{this.name}_raw",*args)
          raise "error returned from fatsecret 1: #{res['error'].inspect}" if res && res['error']
          res = this.process[res] if this.process
          res 
        end
      end
    end
  end
end