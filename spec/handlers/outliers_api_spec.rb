require 'spec_helper'

describe Outliers::Handlers::OutliersApi do
  let(:resource1) {stub 'resource1', id: 1}
  let(:resource2) {stub 'resource2', id: 2}
  let(:result) { Outliers::Result.new account_name:      'cnt',
                                      failing_resources: [resource1],
                                      name:              'evalme',
                                      passing_resources: [resource2],
                                      provider_name:     'aws',
                                      resource_name:     'instance',
                                      verification_name: 'vpc' }
  let(:header) {({ 'Content-Type' => 'application/json',
                   'Accept'       => 'application/vnd.outliers-v1+json' })}
  let(:req) { mock 'req' }
  let(:session) { mock 'session' }
  let(:http) { mock 'http' }

  before { stub_logger }

  context "#post" do
    before do
      Net::HTTP::Post.should_receive(:new).with("/results", header).and_return req
      body = { 'key' => "abc123", 'result' => result.to_hash }.to_json
      req.should_receive(:body=).with(body)
      Net::HTTP.should_receive(:new).with("api.getoutliers.com", 443).and_return session
      session.should_receive(:use_ssl=).with true
    end

    context "when connection established" do
      before do
        session.should_receive(:start).and_yield http
        http.should_receive(:request).with(req).and_return response
      end

      context "when successful" do
        let(:response) { stub 'response', code: "200", body: "Some details." }

        it "should return true" do
          subject.post(result, "abc123", "https://api.getoutliers.com/results").should be_true 
        end
      end

      context "when failure" do
        let(:response) { stub 'response', code: "500", body: "Some details." }

        it "should return false" do
          subject.post(result, "abc123", "https://api.getoutliers.com/results").should be_false 
        end
      end
    end

    context "connection error" do
      it "should return false if connection to url refused." do
        session.should_receive(:start).and_raise Errno::ECONNREFUSED
        subject.post(result, "abc123", "https://api.getoutliers.com/results").should be_false 
      end
    end
  end

end
