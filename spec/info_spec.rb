require 'spec_helper'

describe Outliers::Info do
  it "should be able to load reference.yaml" do
    expect(subject.reference.keys.include?('all')).to be_true
  end

  it "should verify each resource method has a entry in reference.yaml"
  it "should verify each entry in reference.yaml has a resource"
end
