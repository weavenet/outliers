require 'spec_helper'

describe Outliers::Info do
  it "should be able to load verifications.yaml" do
    expect(subject.verifications.keys.include?('all')).to be_true
  end
end
