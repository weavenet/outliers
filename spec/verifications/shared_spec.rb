require 'spec_helper'

describe Outliers::Verifications::Shared do
  subject { Object.new.extend Outliers::Verifications::Shared }
  let(:resource1) { stub "resource1", id: 'resource1' }
  let(:resource2) { stub "resource2", id: 'resource2' }

  before do
    logger_stub = stub 'logger', :debug => true
    subject.stub :logger => logger_stub
  end

  context "#none_exist?" do
    it "should be true if no resources returned" do
      subject.stub :list => []
      expect(subject.none_exist?).to eq([])
    end

    it "should be false if  resources returned" do
      subject.stub :list_by_key => ['resource1']
      subject.stub :list => ['resource1']
      expect(subject.none_exist?).to eq(['resource1'])
    end
  end

  context "#equals?" do
    it "should verify the list of resources equals the list of keys and return no failing reosurces" do
      subject.stub :list_by_key => ['resource1'], :list => [resource1]
      expect(subject.equals?(['resource1'])).to eq([])
    end

    it "should verify the list of resources equals the single key and return no failing resources" do
      subject.stub :list_by_key => ['resource1'], :list => [resource1]
      expect(subject.equals?('resource1')).to eq([])
    end

    it "should return resources which do not match the given list" do
      subject.stub :list_by_key => ['resource1', 'resource2'], :list => [resource1, resource2]
      expect(subject.equals?('resource1')).to eq([resource2])
    end
  end
end
