require 'spec_helper'
require 'spree/testing_support/authorization_helpers'

RSpec.describe Spree::Admin::BaseController, type: :controller do
  controller do
    def index
      render plain: 'test'
    end
  end

  stub_authorization!

  it "passes" do
    get :index
    expect(controller).to be_a_kind_of(described_class)
    expect(response.status).to eq 200
  end
end
