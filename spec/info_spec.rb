require 'spec_helper'

describe Outliers::Info do
  it "should be able to load reference.yaml" do
    expect(subject.reference.keys.include?('all')).to be_true
  end

  it "should verify each resource method has a entry in verifications"
end
