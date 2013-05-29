require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "FatSecret Exercises" do
  let(:api) do
    FatSecret::API.new(:access_token => FatSecret::ACCESS_TOKEN, :access_secret => FatSecret::ACCESS_SECRET)
  end

  let(:params) do
    {:food_id=>800, :food_entry_name=>"Milk", :serving_id=>18, :number_of_units=>1, :meal=>"lunch", :date=>15862}
  end

  it 'smoke' do
    res = api.create_food_entry(params)
    res.should > 0
  end

  it 'get entry' do
    res = api.get_food_entry(830872463)
    res['food_id'].should == '3092'
  end

end
