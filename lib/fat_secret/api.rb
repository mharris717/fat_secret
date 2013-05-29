module FatSecret
  class API
    include FromHash
    include RemoteMethod

    class << self
      attr_accessor :sha1, :site, :digest
    end

    self.sha1 = "HMAC-SHA1" 
    self.site = "http://platform.fatsecret.com/rest/server.api"
    self.digest = OpenSSL::Digest::Digest.new('sha1')

    attr_accessor :access_token, :access_secret

    def consumer_key
      FatSecret::CONSUMER_KEY
    end
    def secret_key
      FatSecret::SECRET_KEY
    end

    def default_params
      {
        :format => 'json',
        :oauth_consumer_key => consumer_key, 
        :oauth_signature_method => klass.sha1, 
        :oauth_timestamp => (Time.now.to_f+0.0).to_i, 
        :oauth_version => "1.0", 
      } 
    end

    def request_obj(http_method,method,other={})
      cache = other[:cache]
      other.delete(:cache)
      Request.get(cache,:api => self, :http_method => http_method.to_s.upcase, :method => method, :other_params => other)
    end
    def request(*args)
      request_obj(*args).results
    end

    def get(*args)
      request(:get,*args)
    end
    def get_cached(*args)
      raise 'get_cached'
      args << {} unless args.last.kind_of?(Hash)
      args.last[:cache] = true
      get(*args)
    end
    def post(*args)
      request(:post,*args)
    end


    remote :find_foods do |t|
      t.cache true
      t.method "foods.search"
      t.request_args do |name|
        [{:search_expression => name}]
      end
      t.process do |res|
        if res['foods']
          res = res['foods']['food']
          res = [res] if res.kind_of?(Hash)
          res
        else
          raise "no foods found for #{name} | #{res.inspect}"
        end
      end
    end

    remote :get_food do |t|
      t.cache true
      t.method "food.get"
      t.request_args do |food|
        if food.kind_of?(Numeric)
          [{:food_id => food}]
        else
          id = find_foods(food).first['food_id'].to_i
          [{:food_id => id}]
        end
      end
      t.process do |res|
        res['food']
      end
    end

    remote :get_exercises do |t|
      t.cache true
      t.method "exercises.get"
      t.process do |res|
        res['exercises']['exercise']
      end
    end

    remote :get_food_entry do |t|
      t.cache true
      t.method "food_entries.get"

      t.request_args do |id|
        [{:food_entry_id => id}]
      end

      t.process do |res|
        res['food_entries']['food_entry']
      end
    end

    remote :create_food_entry do |t|
      t.method "food_entry.create"
      t.process do |res|
        res['food_entry_id']['value'].to_i
      end
    end
 
    def create_food_entry_old(ops)
      ops = {:meal => "lunch"}.merge(ops)
      ops[:date] = ops[:date].days_since_epoch if ops[:date].kind_of?(Time)
      res = get "food_entry.create",ops
      res['food_entry_id']['value'].to_i
    end

    def get_exercise_id(name)
      get_exercises.find { |x| x['exercise_name'] == name }['exercise_id'].andand.to_i
    end

    def log_exercise(name,ops)
      Exercise.new(ops.merge(:name => name, :api => self)).save!
    end

    class Exercise
      include FromHash
      attr_accessor :minutes, :name, :api, :date

      def params
        {:date => date.days_since_epoch, :shift_from_id => 2, :shift_to_id => api.get_exercise_id(name), :minutes => minutes}
      end

      def save!
        api.get('exercise_entry.edit', params)
      end
    end

    def log_weight(lbs)
      raise "bad weight #{lbs}" unless lbs >= 90 && lbs <= 500
      kgs = lbs.to_f / 2.2046
      get "weight.update", :current_weight_kg => kgs, :date => Time.now.days_since_epoch
    end

  end
end