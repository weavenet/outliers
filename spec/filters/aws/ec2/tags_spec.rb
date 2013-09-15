require 'spec_helper'

describe Outliers::Filters::Aws::Ec2::Tags do
  subject do
    object = Object.new
    object.extend Outliers::Filters::Aws::Ec2::Tags
    object
  end

  let(:logger) { stub 'logger', debug: true, info: true }
  let(:tags1) { mock 'tags1' }
  let(:tags2) { mock 'tags2' }
  let(:resource1) { stub 'resource1', tags: tags1, id: 'resource1' }
  let(:resource2) { stub 'resource2', tags: tags2, id: 'resource2' }

  before do
    subject.stub :logger => logger
    subject.stub :list => [resource1, resource2]
  end

  it "should return the list of instances filtered by the given tag name and value" do
    tags1.should_receive(:has_key?).with('Name').and_return true
    tags2.should_receive(:has_key?).with('Name').and_return false
    tags1.should_receive(:[]).with('Name').and_return 'test123'
    expect(subject.filter_tag('Name:test123')).to eq([resource1])
  end
end
