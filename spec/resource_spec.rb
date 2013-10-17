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

  context "#to_human" do
    it "should return the human name for this resource" do
      expect(Outliers::Resources::Aws::Ec2::SecurityGroupCollection.to_human).to eq('aws_ec2_security_group')
      expect(Outliers::Resources::Aws::S3::BucketCollection.to_human).to eq('aws_s3_bucket')
    end
  end

  context "#self.find_by_name" do
    it "should find the resource by name" do
      expect(Outliers::Resource.find_by_name('aws_ec2_instance')).to eq(Outliers::Resources::Aws::Ec2::Instance)
    end

    it "should return nil if the resource can't be found" do
      expect(Outliers::Resource.find_by_name('blah')).to be_nil
    end
  end
end
