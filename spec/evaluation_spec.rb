require 'spec_helper'

describe Outliers::Evaluation do
  let(:run) { mock 'run' }
  let(:connect) { subject.connect('test_account_1') }
  let(:resources) { subject.resources('security_group') }
  subject { Outliers::Evaluation.new :run => run, :name => 'test' }

  before do
    stub_logger
    run.stub :account => account
  end

  context "#connect" do
    it "should connect to the provider" do
      connect
      expect(subject.provider_name_array).to eq(['Aws', 'Ec2'])
    end

    it "should connect to the provider specified as an option" do
      subject.connect('test_account_1', { 'provider' => 'aws_rds' })
      expect(subject.provider_name_array).to eq(['Aws', 'Rds'])
    end

    it "should throw an error if the provider if the provider class is unkown" do
      expect { subject.connect('test_account_1', { 'provider' => 'bad_provider' }) }.
        to raise_error(Outliers::Exceptions::UnknownProvider)
    end

    it "should override a valid provider with one provided" do
      subject.connect('test_account_1', { 'provider' => 'aws_ec2' })
      expect(subject.provider_name_array).to eq(['Aws', 'Ec2'])
    end

    it "should throw an error if the account is unknown" do
      expect { subject.connect('bad_account') }.
        to raise_error(Outliers::Exceptions::UnknownAccount)
    end
  end
    

  context "with connection and resources" do 
    before do
      connect
      resources
    end

    context "#resources" do
      it "should assign the collection_object" do
        expect(subject.resource_collection.class).
          to eq(Outliers::Resources::Aws::Ec2::SecurityGroupCollection)
        expect(subject.resource_collection.provider.class).
          to eq(Outliers::Providers::Aws::Ec2)
      end

      it "should throw an error when given an invalid collection" do
        expect { subject.resources('bad_collection') }.
          to raise_error(Outliers::Exceptions::UnknownCollection)
      end

      it "should test that over ride options are applied when selecting colleciton" do
        subject.connect('test_account_1', :provider => 'aws_rds')
        subject.resources('db_instance')
        expect(subject.resource_collection.provider.class).
          to eq(Outliers::Providers::Aws::Rds)
      end

      context "testing resource assignment" do
        before do
          subject.connect('test_account_1', :provider => 'aws_rds')
        end

        it "should set the collection targets if specified" do
          subject.resources('db_instance', include: 'instance-123')
          expect(subject.resource_collection.targets).to eq ['instance-123']
        end

        it "should send call exclude_by_key with given array" do
          Outliers::Resources::Aws::Rds::DbInstanceCollection.
            any_instance.should_receive(:exclude_by_key).with(['instance-123', 'instance-321'])
          subject.resources('db_instance', exclude: ['instance-123', 'instance-321'])
        end

        it "should convert input to array and send call exclude_by_key with value" do
          Outliers::Resources::Aws::Rds::DbInstanceCollection.
            any_instance.should_receive(:exclude_by_key).with(['instance-123'])
          subject.resources('db_instance', exclude: 'instance-123')
        end

        it "should include the given string as array" do
          subject.resources('db_instance', include: 'instance-123')
          expect(subject.resource_collection.targets).to eq ['instance-123']
        end

        it "should include the array from the include key" do
          subject.resources('db_instance', include: ['instance-123', 'instance-321'])
          expect(subject.resource_collection.targets).to eq ['instance-123', 'instance-321']
        end

        it "should include the array" do
          subject.resources('db_instance', ['instance-123', 'instance-321'])
          expect(subject.resource_collection.targets).to eq ['instance-123', 'instance-321']
        end

        it "should include the string" do
          subject.resources('db_instance', 'instance-123')
          expect(subject.resource_collection.targets).to eq ['instance-123']
        end
      end
    end

    context "#filter" do
      it "should apply the given filter to the collection" do
        resources.should_receive(:filter).with('include', 'tag' => 'Name:test123')
        subject.filter 'include', 'tag' => 'Name:test123'
      end

      it "should convert keys in the args hash to strings" do
        resources.should_receive(:filter).with('include', 'tag' => 'Name:test123')
        subject.filter 'include', tag: 'Name:test123'
      end
    end

    context "#verify" do
      let(:result1) { stub 'result1', :passed? => true }
      let(:result2) { stub 'result2', :passed? => true }
      let(:verification_response) { ( { passing_resources: ['1', '2'], failing_resources: ['3', '4'] } ) }

      before do
        resources.should_receive(:load_all).and_return ['resource1', 'resource2']
        run.stub results: []
      end

      it "should verify the given method" do
        resources.should_receive(:verify).with('test_verification?', nil).and_return verification_response
        Outliers::Result.should_receive(:new).with(account_name:      'test_account_1',
                                                   arguments:         [],
                                                   failing_resources: ['3','4'],
                                                   name:              'test',
                                                   passing_resources: ['1','2'],
                                                   provider_name:     'aws_ec2',
                                                   resource_name:     'security_group',
                                                   verification_name: 'test_verification?').and_return result1
        expect(subject.verify('test_verification?')).to eq([result1])
      end

      it "should convert all options to symbols" do
        resources.should_receive(:verify).with('test_verification?', ['test123']).and_return verification_response
        Outliers::Result.should_receive(:new).with(account_name:      'test_account_1',
                                                   arguments:         ['test123'],
                                                   failing_resources: ['3','4'],
                                                   name:              'test',
                                                   passing_resources: ['1','2'],
                                                   provider_name:     'aws_ec2',
                                                   resource_name:     'security_group',
                                                   verification_name: 'test_verification?').and_return result1
        expect(subject.verify('test_verification?', ['test123'] )).to eq([result1])
      end

      it "should convert arguments string to array in results" do
        resources.should_receive(:verify).with('test_verification?', ['arg']).and_return verification_response
        Outliers::Result.should_receive(:new).with(account_name:      'test_account_1',
                                                   arguments:         ['arg'],
                                                   failing_resources: ['3','4'],
                                                   name:              'test',
                                                   passing_resources: ['1','2'],
                                                   provider_name:     'aws_ec2',
                                                   resource_name:     'security_group',
                                                   verification_name: 'test_verification?').and_return result1
        expect(subject.verify('test_verification?', 'arg' )).to eq([result1])
      end

      it "should raise and error if the arguments are not nil, string or array" do
        expect { subject.verify('test_verification?', arg: 'bad_arg' ) }.
          to raise_error(Outliers::Exceptions::InvalidArguments)
      end

      it "should run verify multiple times in given evaluation" do
        resources.should_receive(:verify).with('test_verification1?', ['arg1']).and_return verification_response
        resources.should_receive(:verify).with('test_verification2?', ['arg2']).and_return verification_response
        Outliers::Result.should_receive(:new).with(account_name:      'test_account_1',
                                                   arguments:         ['arg1'],
                                                   failing_resources: ['3','4'],
                                                   name:              'test',
                                                   passing_resources: ['1','2'],
                                                   provider_name:     'aws_ec2',
                                                   resource_name:     'security_group',
                                                   verification_name: 'test_verification1?').and_return result1
        Outliers::Result.should_receive(:new).with(account_name:      'test_account_1',
                                                   arguments:         ['arg2'],
                                                   failing_resources: ['3','4'],
                                                   name:              'test',
                                                   passing_resources: ['1','2'],
                                                   provider_name:     'aws_ec2',
                                                   resource_name:     'security_group',
                                                   verification_name: 'test_verification2?').and_return result2
        expect(subject.verify('test_verification1?', ['arg1'])).to eq [result1]
        expect(subject.verify('test_verification2?', ['arg2'])).to eq [result1, result2]
      end
    end

  end

end
