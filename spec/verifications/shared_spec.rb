require 'spec_helper'

describe Outliers::Verifications::Shared::Collection do
  subject { Object.new.extend Outliers::Verifications::Shared::Collection }
  let(:resource1) { stub "resource1", id: 'resource1' }
  let(:resource2) { stub "resource2", id: 'resource2' }

  before do
    logger_stub = stub 'logger', :debug => true
    subject.stub :logger => logger_stub
  end

  context "#none_exist?" do
    it "should be true if no resources returned" do
      subject.stub :list => []
      expect(subject.none_exist?).
        to eq({ resources: [], passing: true })
    end

    it "should be false if resource returned" do
      subject.stub :list_by_key => ['resource1'], :list => [resource1]
      expect(subject.none_exist?).
        to eq({ resources: [{ id: 'resource1', status:2 }], passing: false })
    end
  end

  context "#equals?" do
    it "should return passing true if the list matches" do
      subject.stub :list_by_key => ['resource1'], :list => [resource1]
      expect(subject.equals?('resource1')).
        to eq({ resources: [{ id: 'resource1', status:2 }], passing: true })
    end

    it "should return passing false if the resources do match the given list" do
      subject.stub :list_by_key => ['resource1', 'resource2'], :list => [resource1, resource2]
      expect(subject.equals?('resource1')).
        to eq({ resources: [{ id: 'resource1', status:2 },
                            { id: 'resource2', status:2 }], passing: false })
    end

    it "should return passing false if the list is empty" do
      subject.stub :list_by_key => [], :list => []
      expect(subject.equals?('resource1')).
        to eq({ resources: [], passing: false })
    end
  end
end
