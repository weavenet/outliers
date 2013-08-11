require 'spec_helper'

module TestModule
  module TestSubModule
    class TestClass
    end
  end
end

describe do
  context "#all_the_modules" do
    it "should return all the modules and classes for a object recursivley" do
      expect(TestModule.all_the_modules).
        to eq([TestModule, TestModule::TestSubModule, TestModule::TestSubModule::TestClass])
    end
  end
  context "#keys_to_sym" do
    it "should convert all hash keys to symbols" do
      expect({ 'key' => 'val' }.keys_to_sym).to eq({ key: 'val' })
    end
  end
  context "#keys_to_string" do
    it "should convert all hash keys to string" do
      expect({ key: 'val' }.keys_to_s).to eq({ 'key' => 'val' })
    end
  end
  context "#underscore" do
    it "should convert camel case to snack case" do
      expect('TestCamelCase123'.underscore).to eq('test_camel_case123')
      expect('Test123CamelCase'.underscore).to eq('test123_camel_case')
    end
  end
end
