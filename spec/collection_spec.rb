require 'spec_helper'

describe Outliers::Collection do
  let(:provider) { mock 'provider' }
  let(:resource1) { mock 'resource1' }
  let(:resource2) { mock 'resource2' }

  subject { Outliers::Collection.new provider }

  before do
    stub_logger
    resource1.stub name: 'resource1', key: 'name', id: 'resource1'
    resource2.stub name: 'resource2', key: 'name', id: 'resource2'
    subject.stub :load_all => [resource1, resource2],
                 :class => Outliers::Resources::Aws::Ec2::SecurityGroupCollection
  end

  context "#to_human" do
    it "should return the human name for this resource" do
      expect(Outliers::Resources::Aws::Ec2::SecurityGroupCollection.to_human).to eq('aws_ec2_security_group')
      expect(Outliers::Resources::Aws::S3::BucketCollection.to_human).to eq('aws_s3_bucket')
    end
  end

  context "#each" do
    it "should iterate over all resources when block given" do
      expect(subject.each {|r| r}).to eq([resource1, resource2])
    end
  end

  context "#exclude" do
    it "should exclude the given array of resources" do
      subject.exclude_by_key ['resource1']
      expect(subject.all).to eq([resource2])
    end
  end

  context "#key" do
    it "should return the key for the resource" do
      expect(subject.key).to eq('name')
    end
  end

  context "#resource_class" do
    it "should return the resource_class for the resource" do
      expect(subject.resource_class).to eq(Outliers::Resources::Aws::Ec2::SecurityGroup)
    end
  end

  context "#verify" do
    let(:resource_class) {
      m = [:source, :id, :method_missing, :equals?, :none_exist?, :valid_resource?]
      stub 'resource_class', key: 'name',
                             verifications_requiring_target: ['target_me?'],
                             instance_methods: m
    }
    before do
      Outliers::Collection.stub :resource_class => resource_class
    end

    it "should verify the given verification against the colection" do
      expect(subject.verify 'none_exist?', {}).
        to eq( { failing_resources: [resource1, resource2], passing_resources: [] } )
    end

    it "should raise unkown verification if the verification does not exist" do
      expect { subject.verify 'none', {} }.to raise_error Outliers::Exceptions::UnknownVerification
    end

    it "should verify the given verification against the colection with options" do
      expect(subject.verify 'equals?', :keys => ['resource1', 'resource2']).
        to eq( { failing_resources: [], passing_resources: [resource1, resource2] } )
    end

    it "should verify the given verification against each resource in the collection" do
      [resource1, resource2].each {|r| r.define_singleton_method :valid_resource?, lambda { true } }
      expect(subject.verify 'valid_resource?').
        to eq( { failing_resources: [], passing_resources: [resource1, resource2] } )
    end

    it "should appaned a ? to the policy" do
      expect(subject.verify 'none_exist').
        to eq( { failing_resources: [resource1, resource2], passing_resources: [] } )
    end

    it "should remove all but the target resources if one is required and given" do
      subject.targets = ['resource1', 'in-valid']
      resource1.should_receive(:method).with('valid_resource?').and_return(stub 'method', :arity => 0)
      resource1.should_receive(:valid_resource?).and_return false
      expect(subject.verify 'valid_resource?').
        to eq( { failing_resources: [resource1], passing_resources: [] } )
    end

    it "should raise an error if the target resources does not exist" do
      subject.targets = ['in-valid']
      expect { subject.verify 'valid_resource?' }.to raise_error(Outliers::Exceptions::TargetNotFound)
    end
                 
    it "should raise an error if the verification requires arguments and none given" do
      resource1.define_singleton_method :valid_resource?, lambda { |required_args| true }
      expect { subject.verify 'valid_resource?' }.to raise_error(Outliers::Exceptions::ArgumentRequired)
    end

    it "should raise an error if the verification does not require arguments and arguments are given" do
      resource1.define_singleton_method :valid_resource?, lambda { true }
      expect { subject.verify 'valid_resource?', 'unneeded argument' => 3 }.
        to raise_error(Outliers::Exceptions::NoArgumentRequired)
    end

    it "should verify the given verification against each resource in the collection with options" do
      resource1.should_receive(:valid_resource?).with('test_arg' => 2).and_return true
      resource2.should_receive(:valid_resource?).with('test_arg' => 2).and_return true
      expect(subject.verify 'valid_resource?', 'test_arg' => 2).
        to eq( { failing_resources: [], passing_resources: [resource1, resource2] } )
    end
  end

end
