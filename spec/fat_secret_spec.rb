require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'andand'

describe "FatSecret" do
  let(:api) do
    FatSecret::API.new(:access_token => FatSecret::ACCESS_TOKEN, :access_secret => FatSecret::ACCESS_SECRET)
  end

  it 'food get' do
    res = api.get("food.get",:food_id => 800)

    if res.andand['food']
      res['food']['food_name'].should == '2% Fat Milk'
    else
      raise res.inspect
    end
  end

  if false
    it 'food.add_favorite' do
      res = api.get("food.add_favorite", :food_id => 801)
      raise res.inspect
    end
    
    
    it 'food.add_favorite post' do
      res = api.post("food.add_favorite", :food_id => 800)
      raise res.inspect
    end
  end

  it 'get favs' do
    res = api.get("foods.get_favorites")
    require 'pp'
    #pp res
    res['foods']['food'].size.should == 2
  end

  it 'food_entries.get' do
    res = api.get("food_entries.get", :date => Time.local(2013,5,29,12).days_since_epoch)
    #require 'pp'
    #pp res

    res['food_entries']['food_entry'].size.should == 6
    #raise 'foo'
  end

  it 'food_entry.create' do
    ops = {:food_id => 800, :food_entry_name => "Milk", :serving_id => 18, :number_of_units => 1, :meal => "lunch", :date => Time.local(2013,5,28,12).days_since_epoch-1}
    res = api.get('food_entry.create',ops)
    res['food_entry_id']['value'].to_i.should >= 10000
  end

  it 'smoke' do
    2.should == 2
  end

  it 'find_foods' do
    res = api.find_foods('Milk')
    res.class.should == Array

    f = res.first
    f['food_description'].should =~ /Calories/
    f['food_name'].should == '2% Fat Milk'
    f['food_id'].should == "800"
  end

  it 'get_food' do
    res = api.get_food(800)
    res['servings']['serving'].first['serving_id'].should == '18'
  end

  it 'get_food' do
    res = api.get_food('Milk')
    res['servings']['serving'].first['serving_id'].should == '18'
  end
end
