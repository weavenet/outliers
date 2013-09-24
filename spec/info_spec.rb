require 'spec_helper'

describe Outliers::Info do
  context "#reference" do
    before do
      @resources = []
      subject.reference.each_pair do |name,data|
        data['resources'].keys.each do |key|
          @resources << "#{name}_#{key}"
        end
      end
    end

    it "should be able to load reference.yaml" do
      expect(subject.reference.keys.count > 0).to be_true
    end

    it "should verify each provider class has a entry in reference.yaml" do
      expect(subject.reference.keys - ['all']).to eq(Outliers::Providers.name_map.keys)
    end

    it "should verify each resource method has a entry in reference.yaml" do
      expect((@resources - ['all_shared']).sort).to eq(Outliers::Resources.list.map {|r| r.to_human}.sort)
    end

    it "should validate each resource has a verification list, filter list and description" do
      subject.reference.each_value do |provider_data|
        provider_data['resources'].each_value do |resource_data|
          expect(resource_data['verifications'].class).to eq(Hash)
          expect(resource_data['filters'].class).to eq(Hash)
          expect(resource_data['description'].class).to eq(String)
        end
      end
    end

    it "should validate each resource has a list of credentials" do
      subject.reference.each_pair do |name,provider_data|
        expect(provider_data['credentials'].class).to eq(Hash)
      end
    end
  end

  context "#shared" do
    before do
      @verifications = Outliers::Verifications::Shared.instance_methods.map {|m| m.to_s.chomp('?')}
    end

    it "should be able to load shared.yaml" do
      expect(subject.shared.keys.count > 0).to be_true
    end

    it "should verify each shared verfiication method has an entry in shared.yaml" do
      @verifications.each do |name|
        expect(subject.shared['verifications'].keys.include?(name)).to be_true
      end
    end

    it "should verify each verification in shared.yaml has a shared verification method" do
      subject.shared['verifications'].keys.each do |name|
        expect(@verifications.include?(name)).to be_true
      end
    end

  end
end
