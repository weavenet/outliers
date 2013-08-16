require 'spec_helper'

describe Outliers::Run do
  let(:evaluation1) { mock "evaluation1" }
  let(:evaluation2) { mock "evaluation2" }

  before do
    stub_logger
    Outliers.config_path '/test'
  end

  describe "#process_evaluations_in_config_folder" do
    it "should process all .rb files in config folder and sub folders" do
      files = ['/test/test1.rb', '/test/dir', '/test/dir/test2.rb', '/test/dir/test_other_file']
      Dir.should_receive(:glob).with('/test/**/*').and_return files

      ['/test/test1.rb', '/test/dir/test2.rb', '/test/dir/test_other_file'].each do |f|
        File.should_receive(:directory?).with(f).and_return false
      end
      File.should_receive(:directory?).with('/test/dir').and_return true

      File.should_receive(:read).with('/test/test1.rb').and_return evaluation1
      File.should_receive(:read).with('/test/dir/test2.rb').and_return evaluation2
 
      subject.should_receive(:instance_eval).with(evaluation1)
      subject.should_receive(:instance_eval).with(evaluation2)
      subject.process_evaluations_in_config_folder
    end
  end

  describe "#evaluate" do
    it "should kick off a new evaluation and pass the block for execuation" do
      Outliers::Evaluation.should_receive(:new).with(:name => 'my evaluation', :run => subject).and_return evaluation1
      evaluation1.should_receive(:connect).with('test')
      subject.evaluate 'my evaluation' do
        connect 'test'
      end
    end

    it "should kick off a new evaluation with unspecified name" do
      Outliers::Evaluation.should_receive(:new).with(:name => 'unspecified', :run => subject).and_return evaluation1
      evaluation1.should_receive(:connect).with('test')
      subject.evaluate do
        connect 'test'
      end
    end
  end

  context "returning results" do
    let(:result1) { Outliers::Result.new name: 'result1', passing_keys: [], failing_keys: [], evaluation: 'test', verification: 'ver' }
    let(:result2) { Outliers::Result.new name: 'result2', passing_keys: [], failing_keys: ['failed'], evaluation: 'test', verification: 'ver' }

    before do
      subject.results << result1
      subject.results << result2
    end

    describe "#passed" do
      it "should return an array of all passing results" do
        expect(subject.passed).to eq([result1])
      end
    end

    describe "#failed" do
      it "should return an array of all failing results" do
        expect(subject.failed).to eq([result2])
      end
    end
  end

end
