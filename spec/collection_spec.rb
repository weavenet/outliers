require 'spec_helper'

describe Outliers::Collection do
  let(:provider) { mock 'provider' }
  let(:resource1) { mock 'resource1' }
  let(:resource2) { mock 'resource2' }
  let(:resource3) { mock 'resource3' }

  subject { Outliers::Collection.new provider }

  before do
    stub_logger
    resource1.stub name: 'resource1', key: 'name', id: 'resource1'
    resource2.stub name: 'resource2', key: 'name', id: 'resource2'
    subject.stub :load_all => [resource1, resource2],
                 :class    => Outliers::Resources::Aws::Ec2::SecurityGroupCollection
  end

  context "#to_human" do
    it "should return the human name for the resource of the collection" do
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
      expect(subject.list).to eq([resource2])
    end
  end

  context "#verifications" do
    it "should return the shared and collection verifications"
  end

  context "#filter" do
    before do
      subject.instance_variable_set(:@list, [resource1, resource2, resource3])
    end

    it "should include resources matched by include filter" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1]
      subject.filter 'include', tag: 'Name:test123'
      expect(subject.list).to eq([resource1])
    end

    it "should exclude resources matched by exclude filter" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1]
      subject.filter 'exclude', tag: 'Name:test123'
      expect(subject.list).to eq([resource2, resource3])
    end

    it "should apply multiple exclude filters" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1]
      subject.should_receive('filter_tag').with('Name:test321').and_return [resource2]
      subject.filter 'exclude', tag: 'Name:test123'
      subject.filter 'exclude', tag: 'Name:test321'
      expect(subject.list).to eq([resource3])
    end

    it "should apply multiple include filters and only return the union" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1, resource3]
      subject.should_receive('filter_tag').with('Name:test321').and_return [resource2, resource3]
      subject.filter 'include', tag: 'Name:test123'
      subject.filter 'include', tag: 'Name:test321'
      expect(subject.list).to eq([resource3])
    end

    it "should apply exclude and include filters and only return the union" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1, resource3]
      subject.should_receive('filter_tag').with('Name:test321').and_return [resource1, resource2]
      subject.filter 'include', tag: 'Name:test123'
      subject.filter 'exclude', tag: 'Name:test321'
      expect(subject.list).to eq([resource3])
    end

    it "should raise an exception if the filter does not exist" do
      expect { subject.filter('include', 'bogus' => 'Name:test123') }.
        to raise_error Outliers::Exceptions::UnknownFilter
    end

    it "should raise an exception if the filter action does not exist" do
      subject.should_receive('filter_tag').with('Name:test123').and_return [resource1]
      expect { subject.filter('bad_action', 'tag' => 'Name:test123') }.
        to raise_error Outliers::Exceptions::UnknownFilterAction
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
      expect(subject.verify 'none_exist?').
        to eq({ resources: [{ id: "resource1", status: 2 },
                            { id: "resource2", status: 2 }], passing: false })
    end

    it "should raise unkown verification if the verification does not exist" do
      expect { subject.verify 'none' }.to raise_error Outliers::Exceptions::UnknownVerification
    end

    it "should verify the given verification against the colection with options" do
      expect(subject.verify 'equals?', ['resource1', 'resource2']).
        to eq({ resources: [{ id: "resource1", status: 2 },
                            { id: "resource2", status: 2 }], passing: true })
    end

    it "should verify the given verification against each resource in the collection" do
      [resource1, resource2].each {|r| r.define_singleton_method :valid_resource?, lambda { true } }
      expect(subject.verify 'valid_resource?').
        to eq({ resources: [{ id: "resource1", status: 0 },
                            { id: "resource2", status: 0 }], passing: true })
    end

    it "should appaned a ? to the policy" do
      expect(subject.verify 'none_exist').
        to eq({ resources: [{ id: "resource1", status: 2 },
                            { id: "resource2", status: 2 }], passing: false })
    end

    it "should remove all but the target resources if one is required and given" do
      subject.targets = ['resource1', 'in-valid']
      resource1.should_receive(:method).with('valid_resource?').and_return(stub 'method', :arity => 0)
      resource1.should_receive(:valid_resource?).and_return false
      expect(subject.verify 'valid_resource?').
        to eq({ resources: [{ id: "resource1", status: 1 }], passing: false })
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

    it "should return empty resource array if no resources exist in list" do
      subject.stub :load_all => []
      expect(subject.verify 'valid_resource?', {}).
        to eq( { resources: [], passing: true } )
    end

    it "should verify the given verification against each resource in the collection with options" do
      resource1.should_receive(:valid_resource?).with('test_arg' => 2).and_return true
      resource2.should_receive(:valid_resource?).with('test_arg' => 2).and_return true
      expect(subject.verify 'valid_resource?', 'test_arg' => 2).
        to eq( { resources: [ { id: "resource1", status: 0},
                              { id: "resource2", status: 0}], passing: true} )
    end
  end

end
