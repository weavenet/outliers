require 'spec_helper'

describe Outliers::Account do
  subject { Outliers::Account }
  let(:account1) { fixture_file 'account1.yml' }
  let(:account2) { fixture_file 'account2.yml' }

  context "#load_from_file" do
    it "should load the account from the given yaml file" do
      File.should_receive(:read).with('/home/user/outliers.yml').and_return account1
      results = { "test_account_1" => 
                  { "region"            => "us-west-1",
                    "provider"          => "aws_ec2", 
                    "access_key_id"     => "01234567890123456789",
                    "secret_access_key" =>"0123456789012345678901234567890123456789" }
                }
      expect(subject.load_from_file '/home/user/outliers.yml').to eq(results)
    end
  end

end
