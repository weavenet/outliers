require 'spec_helper'

describe Outliers::Result do
  context "passing" do
    subject { Outliers::Result.new evaluation:   'evalme',
                                   failing_keys: [],
                                   passing_keys: ['key1', 'key2'],
                                   resource:     'instance',
                                   verification: 'vpc' }
                                   
    it "should return passed" do
      expect(subject.to_s).to eq 'passed'
    end

    it "should return true for passing verification" do
      expect(subject.passed?).to be_true
    end

    it "should return false for failing verification" do
      expect(subject.failed?).to be_false
    end

    it "should return the result information" do
      expect(subject.passing_keys).to eq(['key1', 'key2'])
    end
  end

  context "failing" do
    subject { Outliers::Result.new evaluation:   'evalme',
                                   failing_keys: ['key3', 'key4'],
                                   passed_keys:  [],
                                   resource:     'instance',
                                   verification: 'vpc' }
    it "should return failed" do
      expect(subject.to_s).to eq 'failed'
    end

    it "should return false for passing verification" do
      expect(subject.passed?).to be_false
    end

    it "should return true for failing verification" do
      expect(subject.failed?).to be_true
    end
  end
end
