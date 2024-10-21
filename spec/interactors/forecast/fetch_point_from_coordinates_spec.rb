require "rails_helper"

RSpec.describe Forecast::FetchPointFromCoordinates do
  describe ".call" do
    context "with valid latitude & longitude" do
      subject(:context) { Forecast::FetchPointFromCoordinates.call(latitude: "34.0901", longitude: "-118.4065") }
      let(:response_body) { <<~JSON }
        {
            "id": "https://api.weather.gov/points/34.0901,-118.4065",
            "properties": {
                "gridId": "LOX",
                "gridX": 149,
                "gridY": 48,
                "forecast": "https://api.weather.gov/gridpoints/LOX/149,48/forecast",
                "forecastHourly": "https://api.weather.gov/gridpoints/LOX/149,48/forecast/hourly",
                "forecastGridData": "https://api.weather.gov/gridpoints/LOX/149,48"
            }
        }
        JSON
      let(:response) { double(:response, body: response_body) }
      let(:conn) { double(:connection) }

      it "fetches and sets the point" do
        allow(Faraday).to receive(:new).with(url: "https://api.weather.gov", headers: { "User-Agent" => "weather-here" }).and_return(conn)
        allow(conn).to receive(:get).with("/points/34.0901,-118.4065").and_return(response)

        expect(context.point.id).to eq "LOX"
        expect(context.point.x).to eq 149
        expect(context.point.y).to eq 48
      end
    end

    context "without coordinates" do
      subject(:context) { Forecast::FetchPointFromCoordinates.call }

      it "fails with an error" do
        expect(context).to be_a_failure
        expect(context.error).to be_present
      end
    end
  end
end

