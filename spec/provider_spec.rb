require 'spec_helper'

describe Outliers::Provider do
  subject { Outliers::Provider }

  context "#find_by_name" do
    it "should return the provider by the given name" do
      expect(subject.find_by_name 'aws_ec2').to eq(Outliers::Providers::Aws::Ec2)
    end

    it "should return nil if name not found" do
      expect(subject.find_by_name 'blah').to be_false
    end
  end

  context "#connect_to" do
    let(:account) { ( { :name               => "test_account_1",
                        "provider"          => "aws_ec2",
                        "secret_access_key" => "abc",
                        "access_key_id"     => "123" } ) }

    it "should connect to the provider specified in the given account" do
      expect(subject.connect_to(account).class).to eq(Outliers::Providers::Aws::Ec2)
    end

    it "should set the account instance variable" do
      expect(subject.connect_to(account).account).
        to eq({ :name               => "test_account_1",
                "provider"          => "aws_ec2",
                "secret_access_key" => "abc",
                "access_key_id"     => "123" })
    end
  end

  context "#collections" do
    it "should return the collections for the provider" do
      expect(Outliers::Providers::Aws::Rds.collections).
       to eq([Outliers::Resources::Aws::Rds::DbInstanceCollection,
              Outliers::Resources::Aws::Rds::DbSnapshotCollection])
    end
  end

  context "#resources" do
    it "should return the resources for the provider" do
      expect(Outliers::Providers::Aws::Rds.resources).
       to eq([Outliers::Resources::Aws::Rds::DbInstance,
              Outliers::Resources::Aws::Rds::DbSnapshot])
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
