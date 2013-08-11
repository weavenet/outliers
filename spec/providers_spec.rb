require 'spec_helper'

describe Outliers::Providers do
  subject { Outliers::Providers }
  before do
    subject.stub :all_the_modules => [Outliers::Providers::Aws, Outliers::Providers::Aws::Ec2]
  end

  it "should return all the providers" do
    expect(subject.all).to eq([Outliers::Providers::Aws::Ec2])
  end

  context "#name_map" do
    it "should return a map of resource human names to objects" do
      expect(subject.name_map).to eq({ 'aws_ec2' => Outliers::Providers::Aws::Ec2 })
    end
  end
end
