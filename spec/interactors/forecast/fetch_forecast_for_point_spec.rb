require "rails_helper"

RSpec.describe Forecast::FetchForecastForPoint do
  describe ".call" do
    context "with valid latitude & longitude" do
      Point = Forecast::FetchPointFromCoordinates::Point

      subject(:context) { Forecast::FetchForecastForPoint.call(point: Point.new(id: "LOX", x: 149, y: 48)) }
      let(:response_body) { <<~JSON }
        {
            "properties": {
                "units": "us",
                "forecastGenerator": "HourlyForecastGenerator",
                "generatedAt": "2024-10-21T06:57:02+00:00",
                "updateTime": "2024-10-21T04:43:56+00:00",
                "validTimes": "2024-10-20T22:00:00+00:00/P7DT3H",
                "elevation": {
                    "unitCode": "wmoUnit:m",
                    "value": 235.9152
                },
                "periods": [
                    {
                        "number": 1,
                        "name": "",
                        "startTime": "2024-10-20T23:00:00-07:00",
                        "endTime": "2024-10-21T00:00:00-07:00",
                        "isDaytime": false,
                        "temperature": 67,
                        "temperatureUnit": "F",
                        "temperatureTrend": "",
                        "probabilityOfPrecipitation": {
                            "unitCode": "wmoUnit:percent",
                            "value": 0
                        },
                        "dewpoint": {
                            "unitCode": "wmoUnit:degC",
                            "value": 5.555555555555555
                        },
                        "relativeHumidity": {
                            "unitCode": "wmoUnit:percent",
                            "value": 41
                        },
                        "windSpeed": "5 mph",
                        "windDirection": "N",
                        "icon": "https://api.weather.gov/icons/land/night/few?size=small",
                        "shortForecast": "Mostly Clear",
                        "detailedForecast": ""
                    }
                ]
            }
        }
        JSON
      let(:response) { double(:response, body: response_body) }
      let(:conn) { double(:connection) }

      it "fetches and sets the forecast" do
        allow(Faraday).to receive(:new).with(url: "https://api.weather.gov", headers: { "User-Agent" => "weather-here" }).and_return(conn)
        allow(conn).to receive(:get).with("/gridpoints/LOX/149,48/forecast/hourly").and_return(response)

        f = context.forecast
        expect(f.temperature).to eq 67
        expect(f.short_forecast).to eq "Mostly Clear"
        expect(f.icon).to eq "https://api.weather.gov/icons/land/night/few?size=small"
      end
    end

    context "with a missing point" do
      subject(:context) { Forecast::FetchForecastForPoint.call }

      it "fails with an error" do
        expect(context).to be_a_failure
        expect(context.error).to be_present
      end
    end
  end
end

