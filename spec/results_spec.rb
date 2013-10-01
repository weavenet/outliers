require 'spec_helper'

describe Outliers::Result do
  let(:resource1) {stub 'resource1', id: 1}
  let(:resource2) {stub 'resource1', id: 2}

  context "passing" do
    subject { Outliers::Result.new credentials_name:  'cnt',
                                   failing_resources: [],
                                   name:              'evalme',
                                   passing_resources: [resource1, resource2],
                                   provider_name:     'aws',
                                   resource_name:     'instance',
                                   verification_name: 'vpc' }

    it "should return true for passing verification" do
      expect(subject.passed?).to be_true
    end

    it "should return false for failing verification" do
      expect(subject.failed?).to be_false
    end

    it "should return the result information" do
      expect(subject.passing_resources).to eq([resource1, resource2])
    end

    it "should return the result information" do
      expect(subject.credentials_name).to eq('cnt')
      expect(subject.failing_resources).to eq([])
      expect(subject.name).to eq('evalme')
      expect(subject.passing_resources).to eq([resource1, resource2])
      expect(subject.provider_name).to eq('aws')
      expect(subject.resource_name).to eq('instance')
      expect(subject.verification_name).to eq('vpc')
    end

    context "#to_json" do
      it "should return the results as json" do
        json =  { 'credentials_name'     => 'cnt',
                  'failing_resource_ids' => [].map{|r| r.id},
                  'name'                 => 'evalme',
                  'passing_resource_ids' => [resource1, resource2].map{|r| r.id},
                  'provider_name'        => 'aws',
                  'resource_name'        => 'instance',
                  'verification_name'    => 'vpc' }.to_json
        expect(subject.to_json).to eq(json)
      end
    end
  end

  context "failing" do
    subject { Outliers::Result.new credentials_name:  'cnt',
                                   failing_resources: [resource1, resource2],
                                   name:              'evalme',
                                   passing_resources: [],
                                   provider_name:     'aws',
                                   resource_name:     'instance',
                                   verification_name: 'vpc' }

    it "should return false for passing verification" do
      expect(subject.passed?).to be_false
    end

    it "should return true for failing verification" do
      expect(subject.failed?).to be_true
    end
  end
end
