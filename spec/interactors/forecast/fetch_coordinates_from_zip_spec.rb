require "rails_helper"

EX_RESP_BODY = <<~JSON
  {
    "post code": "90210",
    "country": "United States",
    "country abbreviation": "US",
    "places": [
      {
        "place name": "Beverly Hills",
        "longitude": "-118.4065",
        "state": "California",
        "state abbreviation": "CA",
        "latitude": "34.0901"
      }
    ]
  }
  JSON

RSpec.describe Forecast::FetchCoordinatesFromZip do
  describe ".call" do
    context "with a valid zip" do
      subject(:context) { Forecast::FetchCoordinatesFromZip.call(zip: "90210") }
      let(:response) { double(:response, body: EX_RESP_BODY) }

      it "fetches and sets coordinates" do
        allow(Faraday).to receive(:get).with("https://api.zippopotam.us/us/90210").and_return(response)

        expect(context.latitude).to eq "34.0901"
        expect(context.longitude).to eq "-118.4065"
      end
    end

    context "with an invalid zip" do
      subject(:context) { Forecast::FetchCoordinatesFromZip.call(zip: "XXXXX") }

      it "fails with an error" do
        expect(context).to be_a_failure
        expect(context.error).to_not be_blank
      end
    end
  end
end

