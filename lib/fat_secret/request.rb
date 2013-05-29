module FatSecret
  class Request
    include FromHash
    attr_accessor :api
    attr_accessor :http_method, :method

    fattr(:nonce) do
      rand(1000000000).to_s
    end
    fattr(:other_params) { {} }
    fattr(:full_specific_params) do
      other_params.merge(:method => method)
    end
    fattr(:params_no_token) do
      api.default_params.merge(:oauth_nonce => nonce).merge(full_specific_params)
    end
    fattr(:full_params) do
      res = params_no_token
      res = res.merge(:oauth_token => api.access_token)# if use_access_token?
      res
    end

    fattr(:base_string) do
      list = [http_method.esc,API.site.esc,http_params_str.esc]
      #puts "\n\nescaping #{list.inspect}\n\n"
      list.join("&")
    end

    fattr(:http_params_str) do
      full_params.sort_by_key.map { |k,v| "#{k.to_s}=#{v}" }.join("&")
    end

    def use_access_token?
      return true
      method != "food.get"
    end

    fattr(:signature) do
      secret_token = "#{api.secret_key}&#{use_access_token? ? api.access_secret.andand.esc : nil}"
      Base64.encode64(OpenSSL::HMAC.digest(API.digest, secret_token, base_string)).gsub(/\n/, '').esc 
    end

    fattr(:uri) do
      parts = http_params_str.split('&') 
      parts << "oauth_signature=#{signature}" 
      #puts "signature is #{signature}"
      URI.parse("#{API.site}?#{parts.join('&')}") 
    end

    def wait_till_ready
      return
      loop do
        return if full_params[:oauth_timestamp] == Time.now.to_i
        sleep(0.03)
      end
    end

    def raw_results_remote
      if http_method.to_s.upcase == 'GET'
        HttpApi.get(uri)
      elsif http_method.to_s.upcase == 'POST'
        HttpApi.post_form(uri,full_params).body
      else
        raise "bad method #{http_method}"
      end
    end
    def raw_results
      raw_results_remote
    end

    fattr(:results) do
      JSON.parse(raw_results)
    end

    class << self
      def get(cache,ops={})
        #cache = true if ops[:method] == ""
        #puts "non caching request #{ops.inspect}" unless cache
        cls = (cache ? CachingRequest : Request)
        cls = Request
        cls.new(ops)
      end
    end
  end

  class CachingRequest < Request
    fattr(:raw_results) do
      Cache.get(:request_results,full_specific_params) do
        raw_results_remote
      end
    end
  end
end