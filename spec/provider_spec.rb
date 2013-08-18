require 'spec_helper'

describe Outliers::Provider do
  subject { Outliers::Provider }

  context "#connect_to" do
    let(:credentials) { ( { :name               => "test_credentials_1",
                            "provider"          => "aws_ec2",
                            "secret_access_key" => "abc",
                            "access_key_id"     => "123" } ) }

    it "should connect to the provider specified in the given credentials" do
      expect(subject.connect_to(credentials).class).to eq(Outliers::Providers::Aws::Ec2)
    end

    it "should set the credentials instance variable" do
      expect(subject.connect_to(credentials).credentials).
        to eq({ :name               => "test_credentials_1",
                "provider"          => "aws_ec2",
                "secret_access_key" => "abc",
                "access_key_id"     => "123" })
    end
  end

  context "#to_human" do
    it "should return the name a human would use to access the provider" do
      expect(Outliers::Providers::Aws::Rds.to_human).to eq('aws_rds')
    end

    it "should return the name a human would use to access the provider" do
      expect(Outliers::Providers::Aws::CloudFormation.to_human).to eq('aws_cloud_formation')
    end
  end

end
