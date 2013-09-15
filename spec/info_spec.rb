require 'spec_helper'

describe Outliers::Info do
  context "#reference" do
    it "should be able to load reference.yaml" do
      expect(subject.reference.keys.include?('all')).to be_true
    end

    it "should verify each provider class has a entry in reference.yaml" do
      expect(subject.reference.keys - ['all']).to eq(Outliers::Providers.name_map.keys)
    end

    it "should verify each resource method has a entry in reference.yaml" do
      result = []
      subject.reference.each_pair do |name,data|
        data['resources'].keys.each do |key|
          result << "#{name}_#{key}"
        end
      end
      expect((result - ['all_shared']).sort).to eq(Outliers::Resources.list.map {|r| r.to_human}.sort)
    end
  end
end
