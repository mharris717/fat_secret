require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "FatSecret Weight" do
  let(:api) do
    FatSecret::API.new(:access_token => FatSecret::ACCESS_TOKEN, :access_secret => FatSecret::ACCESS_SECRET)
  end

  it 'works' do
    api.log_weight 200
    2.should == 2
  end
end