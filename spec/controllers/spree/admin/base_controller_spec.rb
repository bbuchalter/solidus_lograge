require 'spec_helper'
require 'spree/testing_support/authorization_helpers'

RSpec.describe Spree::Admin::BaseController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  stub_authorization!

  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end
  let(:log_json) { JSON.parse(log_output.string) }

  before do
    Lograge.logger = logger
    Lograge.formatter = Lograge::Formatters::Json.new
  end

  it "passes" do
    get :index
    expect(controller).to be_a_kind_of(described_class)
    expect(response.status).to eq 200
  end

  it "records" do
    get :index
    expect(log_json["method"]).to eq "GET"
  end
end
