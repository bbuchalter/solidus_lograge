require 'spec_helper'
require 'timecop'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg } }
  end
  let(:log_json) { JSON.parse(log_output.string) }

  before do
    Lograge.logger = logger
  end

  it "passes" do
    get :index
    expect(controller).to be_a_kind_of(described_class)
    expect(response.status).to eq 200
  end

  it "records HTTP method" do
    get :index
    expect(log_json["method"]).to eq "GET"
  end

  it "records request path" do
    get :index
    expect(log_json["path"]).to eq "/anonymous"
  end

  it "excludes query params from request path" do
    get :index, query_params: "false"
    expect(log_json["path"]).to eq "/anonymous"
  end

  it "record requst params" do
    get :index, fun: 1
    expect(log_json["params"]).to eq("{\"fun\"=>\"1\"}")
  end

  it "records Rails request format" do
    get :index
    expect(log_json["format"]).to eq("html")
  end

  it "records Rails controller action" do
    get :index
    expect(log_json["action"]).to eq("index")
  end

  it "records Rails controller action" do
    get :index
    expect(log_json["action"]).to eq("index")
  end

  it "records Rails environment" do
    get :index
    expect(log_json["env"]).to eq("test")
  end

  describe "timestamp" do
    before { Timecop.freeze(Time.utc(2006)) }
    after { Timecop.return }
    it "is recorded" do
      get :index
      expect(log_json["timestamp"]).to eq("2006-01-01T00:00:00Z")
    end
  end

  it "records db_runtime" do
    get :index
    expect(log_json["db"]).to be_present
  end

  it "records view_runtime" do
    get :index
    expect(log_json["view"]).to be_present
  end

  it "records total runtime" do
    get :index
    expect(log_json["total"]).to be_present
  end

  describe "status" do
    it "records 200" do
      get :index
      expect(log_json["status"]).to eq 200
    end
  end

  context "when an exception occurs" do
    controller do
      def index
        render plain: "Error!", status: 500
      end
    end

    describe "status" do
      it "records 500" do
        get :index
        expect(response.status).to eq 500
        expect(log_json["status"]).to eq 500
      end
    end
  end

  it "records request IP" do
    get :index
    expect(log_json["ip"]).to eq "0.0.0.0"
  end

  context "host" do
    before { request.host = "my.awesome.host" }
    it "is recorded" do
      get :index
      expect(log_json["host"]).to eq "my.awesome.host"
    end
  end

  it "records user agent" do
    get :index
    expect(log_json["user_agent"]).to eq "Rails Testing"
  end

  context "masquerading_user" do
    before { session["devise_masquerade_spree_user"] = 1 }

    it "is recorded" do
      get :index
      expect(log_json["masquerading_user"]).to eq 1
    end
  end
end
