require "spec_helper"
require 'spree/testing_support/factories'

RSpec.describe "logging the front end", type: :feature do
  let(:log_output) { StringIO.new }
  let(:logger) do
    Logger.new(log_output).tap { |logger| logger.formatter = ->(_, _, _, msg) { msg + "\n" } }
  end
  let(:last_log_json) { JSON.parse(log_output.string.split("\n").last) }

  before do
    FactoryGirl.create(:store)
    FactoryGirl.create(:product, name: "RoR Mug")
    Lograge.logger = logger
  end

  scenario "when no order is set" do
    visit spree.root_path
    expect(last_log_json["order"]).to eq nil
  end

  scenario "when an order is set" do
    visit spree.root_path
    click_link "RoR Mug"
    click_button "add-to-cart-button"
    visit spree.cart_path
    expect(last_log_json["order"]).to be_present
  end
end
