require 'spec_helper'

describe Outliers::Result do
  context "passing" do
    subject { Outliers::Result.new description: 'stuff', passed: true }
    it "should return passed" do
      expect(subject.to_s).to eq 'passed'
    end

    it "should return true for passing verification" do
      expect(subject.passed?).to be_true
    end

    it "should return false for passing verification" do
      expect(subject.failed?).to be_false
    end
  end

  context "failing" do
    subject { Outliers::Result.new description: 'stuff', passed: false }
    it "should return passed" do
      expect(subject.to_s).to eq 'failed'
    end

    it "should return false for failing verification" do
      expect(subject.passed?).to be_false
    end

    it "should return true for failing verification" do
      expect(subject.failed?).to be_true
    end
  end
end
