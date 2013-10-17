require 'spec_helper'

describe Outliers::Resources do
  subject { Outliers::Resources }
  before do
      Outliers::Resources.stub :all_the_modules => [Outliers::Resources::Aws::Ec2, 
                                                    Outliers::Resources::Aws::Ec2::SecurityGroup,
                                                    Outliers::Resources::Aws::Ec2::SecurityGroupCollection]
  end

  context "#collection" do
    it "should return all the collections" do
      expect(subject.collections).to eq([Outliers::Resources::Aws::Ec2::SecurityGroupCollection])
    end
  end

  context "#resources" do
    it "should return all the resources" do
      expect(subject.resources).to eq([Outliers::Resources::Aws::Ec2::SecurityGroup])
    end
  end

end
