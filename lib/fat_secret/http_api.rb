class HttpApi
  class << self
    def get(uri)
      #return Net::HTTP.get(uri)
      if uri.to_s =~ /exercise_entry\.edit/
        {}.to_json
      elsif uri.to_s =~ /weight\.update/
        {}.to_json
      elsif uri.to_s =~ /food_entry\.create/
        {"food_entry_id" => {"value" => "1234567"}}.to_json
      elsif uri.to_s =~ /food_entries\.get/
        if uri.to_s =~ /830872463/
          {"food_entries" => {"food_entry" => {"food_id" => "3092"}}}.to_json
        else
          {"food_entries" => {"food_entry" => [1,1,1,1,1,1]}}.to_json
        end
      elsif uri.to_s =~ /foods\.get_favorites/
        {"foods" => {"food" => [1,1]}}.to_json
      elsif uri.to_s =~ /food\.get/
        {"food" => {"food_name" => '2% Fat Milk', 'servings' => {'serving' => [{'serving_id' => '18'}]}}}.to_json
      elsif uri.to_s =~ /foods\.search/
        h = {"food_description" => "Calories", "food_name" => "2% Fat Milk", "food_id" => "800"}
        {"foods" => {"food" => [h]}}.to_json
      elsif uri.to_s =~ /exercises\.get/
        list = []
        list << {"exercise_name" => "Exercise Walking", 'exercise_id' => '58'}
        list << {'exercise_name' => 'Resting', 'exercise_id' => '2'}
        69.times do
          list << {}
        end

        {"exercises" => {"exercise" => list}}.to_json
      else
        raise uri.inspect
        #Net::HTTP.get(uri)
      end
    end
  end
end

#['food_entries']['food_entry']f['food_description'].should =~ /Calories/
