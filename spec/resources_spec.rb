require 'spec_helper'

describe Outliers::Resources do
  subject { Outliers::Resources }

  context "#collections" do
    it "should return all the collections" do
      Outliers::Resources.stub :all_the_modules => [Outliers::Resources::Aws::Ec2, 
                                                    Outliers::Resources::Aws::Ec2::SecurityGroup,
                                                    Outliers::Resources::Aws::Ec2::SecurityGroupCollection]
      expect(subject.collections).to eq([Outliers::Resources::Aws::Ec2::SecurityGroupCollection])
    end
  end

end
