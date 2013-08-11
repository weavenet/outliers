require 'spec_helper'

describe Outliers::Evaluation do
  let(:run) { mock 'run' }
  let(:result) { mock 'result' }
  let(:connect) { subject.connect('test_credentials_1') }
  let(:resources) { subject.resources('security_group') }
  subject { Outliers::Evaluation.new :run => run, :name => 'test' }

  before do
    stub_logger
    run.stub :credentials => credentials
  end

  context "#connect" do
    it "should connect to the provider" do
      connect
      expect(subject.provider_name_array).to eq(['Aws', 'Ec2'])
    end

    it "should connect to the provider specified as an option" do
      subject.connect('test_credentials_1', { 'provider' => 'aws_rds' })
      expect(subject.provider_name_array).to eq(['Aws', 'Rds'])
    end

    it "should throw an error if the provider if the provider class is unkown" do
      expect { subject.connect('test_credentials_1', { 'provider' => 'bad_provider' }) }.
        to raise_error(Outliers::Exceptions::UnknownProvider)
    end

    it "should override a valid provider with one provided" do
      subject.connect('test_credentials_1', { 'provider' => 'aws_ec2' })
      expect(subject.provider_name_array).to eq(['Aws', 'Ec2'])
    end
  end

  context "with connection and resources" do 
    before do
      connect
      resources
    end

    context "#resources" do
      it "should assign the collection_object" do
        expect(subject.collection.class).
          to eq(Outliers::Resources::Aws::Ec2::SecurityGroupCollection)
        expect(subject.collection.provider.class).
          to eq(Outliers::Providers::Aws::Ec2)
      end

      it "should throw an error when given an invalid collection" do
        expect { subject.resources('bad_collection') }.
          to raise_error(Outliers::Exceptions::UnknownCollection)
      end

      it "should test that over ride options are applied when selecting colleciton" do
        subject.connect('test_credentials_1', :provider => 'aws_rds')
        subject.resources('db_instance')
        expect(subject.collection.provider.class).
          to eq(Outliers::Providers::Aws::Rds)
      end

      it "should set the collection targets if specified" do
        subject.connect('test_credentials_1', :provider => 'aws_rds')
        expect(subject.resources('db_instance', 'instance-123').targets).to eq ['instance-123']
      end
    end

    context "#exclude" do
      it "should convert input to array and send call exclude_by_key with value" do
        resources.should_receive(:exclude_by_key).with(['test'])
        subject.exclude 'test'
      end
    end

    context "#verify" do
      before do
        resources.should_receive(:load_all)
        Outliers::Result.should_receive(:new).with(description: 'test', :passed => true).and_return result
        run.should_receive(:results).and_return([])
      end

      it "should verify the given method" do
        resources.should_receive(:verify).with('test_verification?', {}).and_return(true)
        expect(subject.verify('test_verification?', {})).to eq([result])
      end

      it "should convert all options to symbols" do
        resources.should_receive(:verify).with('test_verification?', :test => false).and_return(true)
        expect(subject.verify('test_verification?', { 'test' => false } )).to eq([result])
      end
    end

  end

end
