require 'spec_helper'

describe Outliers::Result do
  context "passing" do
    subject { Outliers::Result.new credentials_name:  'cnt',
                                   failing_resources: [],
                                   name:              'evalme',
                                   passing_resources: ['key1', 'key2'],
                                   provider_name:     'aws',
                                   resource_name:     'instance',
                                   verification_name: 'vpc' }
                                   
    it "should return passed" do
      expect(subject.to_s).to eq 'passed'
    end

    it "should return true for passing verification" do
      expect(subject.passed?).to be_true
    end

    it "should return false for failing verification" do
      expect(subject.failed?).to be_false
    end

    it "should return the result information" do
      expect(subject.passing_resources).to eq(['key1', 'key2'])
    end

    it "should return the result information" do
      expect(subject.credentials_name).to eq('cnt')
      expect(subject.failing_resources).to eq([])
      expect(subject.name).to eq('evalme')
      expect(subject.passing_resources).to eq(['key1','key2'])
      expect(subject.provider_name).to eq('aws')
      expect(subject.resource_name).to eq('instance')
      expect(subject.verification_name).to eq('vpc')
    end

    context "with ?" do
      subject { Outliers::Result.new verification_name:  'vpc?' }
      it "should remove question mark from verification names" do
        expect(subject.verification_name).to eq('vpc')
      end
    end
  end

  context "failing" do
    subject { Outliers::Result.new credentials_name:  'cnt',
                                   failing_resources: ['key3', 'key4'],
                                   name:              'evalme',
                                   passing_resources: [],
                                   provider_name:     'aws',
                                   resource_name:     'instance',
                                   verification_name: 'vpc' }
    it "should return failed" do
      expect(subject.to_s).to eq 'failed'
    end

    it "should return false for passing verification" do
      expect(subject.passed?).to be_false
    end

    it "should return true for failing verification" do
      expect(subject.failed?).to be_true
    end
  end
end
