require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'andand'

describe "FatSecret Exercises" do
  let(:api) do
    FatSecret::API.new(:access_token => FatSecret::ACCESS_TOKEN, :access_secret => FatSecret::ACCESS_SECRET)
  end

  it 'list' do
    #raise api.get_exercises.inspect[0...1000]
    api.get_exercises.size.should == 71
    #raise api.get_exercises.map { |x| x['exercise_name'] }.sort.inspect
  end

  it 'single' do
    api.get_exercise_id('Exercise Walking').should == 58
  end
  it 'resting' do
    api.get_exercise_id('Resting').should == 2
  end

  it 'log' do
    api.log_exercise('Exercise Walking', :date => Time.now, :minutes => 50)

  end

end