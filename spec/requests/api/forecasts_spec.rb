require "rails_helper"

RSpec.describe "Forecast API", type: :request do
  ForecastData = Struct.new(:starts_at, :ends_at, :temperature, :short_forecast, :icon, :cached)
  describe "GET /api/forecasts/zip/:zip" do
    context "with a valid zip" do
      let(:data) do
        fd = ForecastData.new(starts_at: "2024-10-20T23:00:00-07:00",
                              ends_at: "2024-10-21T06:00:00-07:00",
                              temperature: 67,
                              short_forecast: "Mostly Clear",
                              icon: "https://api.weather.gov/icons/land/night/few?size=small")
        OpenStruct.new(forecast: fd)
      end
      it "returns a current temperature for a zip code" do
        allow(Forecast::GetForecastFromZip).to receive(:call).with(zip: "90210").and_return(data)
        get "/api/forecasts/zip/90210.json"

        expect(response).to have_http_status(:success)

        j = JSON.parse(response.body)
        expect(j["temperature"]).to eq 67
      end
    end
  end

  describe "GET /api/forecasts/address/:address" do
    context "with a valid address" do
      let(:data) do
        fd = ForecastData.new(starts_at: "2024-10-20T23:00:00-07:00",
                              ends_at: "2024-10-21T06:00:00-07:00",
                              temperature: 67,
                              short_forecast: "Mostly Clear",
                              icon: "https://api.weather.gov/icons/land/night/few?size=small")
        OpenStruct.new(forecast: fd)
      end

      it "returns a current temperature for a valid address" do
        allow(Forecast::GetForecastFromZip).to receive(:call).with(zip: "90210").and_return(data)
        get "/api/forecasts/address/xxx%2090210.json"

        expect(response).to have_http_status(:success)

        j = JSON.parse(response.body)
        expect(j["temperature"]).to eq 67
      end
    end

  end
end

