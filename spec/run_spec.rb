require 'spec_helper'

describe Outliers::Run do
  let(:evaluation1) { mock "evaluation1" }
  let(:evaluation2) { mock "evaluation2" }

  before do
    stub_logger
  end

  describe "#process_evaluations_in_config_folder" do
    it "should process all evaluation files in config folder" do
      Dir.should_receive(:entries).with('/test').and_return ['.', '..', 'test1.rb', 'test2.rb']
      File.should_receive(:read).with('/test/test1.rb').and_return evaluation1
      File.should_receive(:read).with('/test/test2.rb').and_return evaluation2
 
      subject.should_receive(:instance_eval).with(evaluation1)
      subject.should_receive(:instance_eval).with(evaluation2)
      subject.process_evaluations_in_config_folder
    end

    it "should skip directories"
    it "should only evaluate .rb files"
  end

  describe "#evaluate" do
    it "should kick off a new evaluation and yield it to the block" do
      Outliers::Evaluation.should_receive(:new).with(:name => 'my evaluation', :run => subject).and_return evaluation1
      subject.evaluate('my evaluation') do |e|
        expect(e).to eq(evaluation1)
      end
    end
  end

  context "returning results" do
    let(:result1) { Outliers::Result.new description: 'result1', passed: true }
    let(:result2) { Outliers::Result.new description: 'result2', passed: false }
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
