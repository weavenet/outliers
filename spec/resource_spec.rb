require 'spec_helper'

describe Outliers::Resource do
  let(:provider) { mock 'provider' }
  subject { Outliers::Resource.new provider }

  context "#method_missing" do
    it "should send missing methods to the source object" do
      provider.stub :test_method => true
      expect(subject.send 'test_method').to be_true
    end
  end

  context "#self.key" do
    it "should valid key returns name" do
      expect(Outliers::Resource.key).to eq('name')
    end
  end
end
