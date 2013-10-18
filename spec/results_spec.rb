require 'spec_helper'

describe Outliers::Result do
  let(:resource1) {stub 'resource1', id: 1}
  let(:resource2) {stub 'resource2', id: 2}

  context "passing" do
    subject { Outliers::Result.new account_name:      'cnt',
                                   arguments:         ['test123'],
                                   name:              'evalme',
                                   resources:         [{ id: 'resource1', status: 0 },
                                                       { id: 'resource1', status: 0 }],
                                   passing:           true,
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
      expect(subject.account_name).to eq('cnt')
      expect(subject.resources).to eq([{ id: 'resource1', status: 0 },
                                       { id: 'resource1', status: 0 }])
      expect(subject.name).to eq('evalme')
      expect(subject.passing).to eq(true)
      expect(subject.passed?).to eq(true)
      expect(subject.failed?).to eq(false)
      expect(subject.provider_name).to eq('aws')
      expect(subject.resource_name).to eq('instance')
      expect(subject.verification_name).to eq('vpc')
    end

    context "#name" do
      subject { Outliers::Result.new({}) }

      it "should set the name to unspecified if not set" do
        expect(subject.name).to eq('unspecified')
      end
    end

    context "#to_json" do
      it "should return the results as json" do
        json =  { 'account_name'         => 'cnt',
                  'arguments'            => ['test123'],
                  'name'                 => 'evalme',
                  'passing'              => true,
                  'provider_name'        => 'aws',
                  'resource_name'        => 'instance',
                  'verification_name'    => 'vpc',
                  'resources'            => [{ id: 'resource1', status: 0 },
                                             { id: 'resource1', status: 0 }] }.to_json
        expect(subject.to_json).to eq(json)
      end
    end

    context "#to_hash" do
      it "should return the results as hash" do
        hash =  { 'account_name'         => 'cnt',
                  'arguments'            => ['test123'],
                  'name'                 => 'evalme',
                  'passing'              => true,
                  'provider_name'        => 'aws',
                  'resource_name'        => 'instance',
                  'verification_name'    => 'vpc',
                  'resources'            => [{ id: 'resource1', status: 0 },
                                             { id: 'resource1', status: 0 }] }.to_hash
        expect(subject.to_hash).to eq(hash)
      end
    end
  end

  context "failing" do
    subject { Outliers::Result.new account_name:      'cnt',
                                   arguments:         ['test123'],
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
