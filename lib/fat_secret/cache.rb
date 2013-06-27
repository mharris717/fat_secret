module FatSecret
  class Cache
    class << self
      fattr(:instance) { new }
      def method_missing(sym,*args,&b)
        instance.send(sym,*args,&b)
      end
    end

    fattr(:redis) do
      Redis.new
    end

    def get_inner(*args,&b)
      k = args.join("-")
      exist = redis.get(k)
      if exist && !error_return?(exist)
        #puts "exists #{exist.inspect}END"
        exist
      elsif block_given?
        #raise "getting remote for\n\n#{k}\n\n#{args.inspect}\n\n"
        fresh = yield
        redis.set(k,fresh)
        fresh
      else
        exist
      end
    end

    def get(*args,&b)
      res = get_inner(*args,&b)
      #puts "get class #{res.class}"
      res
    end

    def error_return?(str)
      if str.blank?
        false
      else
        res = JSON.parse(str)
        res && res['error']
      end
    rescue => exp
      return false
    end
  end
end