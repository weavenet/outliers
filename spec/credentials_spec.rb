require 'spec_helper'

describe Outliers::Credentials do
  subject { Outliers::Credentials }
  let(:credentials1) { fixture_file 'credentials1.yml' }
  let(:credentials2) { fixture_file 'credentials2.yml' }

  context "#load_from_file" do
    it "should load the credentials from the given yaml file" do
      File.should_receive(:read).with('/home/user/outliers.yml').and_return credentials1
      results = { "test_credentials_1" => 
                  { "region"            => "us-west-1",
                    "provider"          => "aws_ec2", 
                    "access_key_id"     => "01234567890123456789",
                    "secret_access_key" =>"0123456789012345678901234567890123456789" }
                }
      expect(subject.load_from_file '/home/user/outliers.yml').to eq(results)
    end
  end

end
