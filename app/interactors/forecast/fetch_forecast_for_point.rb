
class Forecast::FetchForecastForPoint
  include Interactor

  # Expects [grid]point in context
  # Sets context forecast

  FORECAST_HOST = "https://api.weather.gov"

  ForecastData = Struct.new(:starts_at, :ends_at, :temperature, :short_forecast, :icon)

  def call
    context.fail!(error: "Missing point") unless valid_point?

    response_json = parse_response(fetch_forecast)

    current_forecast = response_json.dig("properties", "periods")&.first
    context.fail!(error: "No forecast") unless current_forecast

    starts_at = current_forecast["startTime"]
    ends_at = current_forecast["endTime"]
    temperature = current_forecast["temperature"]
    short_forecast = current_forecast["shortForecast"]
    icon = current_forecast["icon"]

    set_forecast(starts_at, ends_at, temperature, short_forecast, icon)
  end

  private

  def set_forecast(starts_at, ends_at, temperature, short_forecast, icon)
    context.forecast = ForecastData.new(starts_at: starts_at,
                                        ends_at: ends_at,
                                        temperature: temperature,
                                        short_forecast: short_forecast,
                                        icon: icon)
  end

  def parse_response(response)
    begin
      JSON.parse(response.body)
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def fetch_forecast
    begin
      conn = Faraday.new(
        url: FORECAST_HOST,
        headers: { "User-Agent" => Rails.application.name }
      )

      p = context.point
      conn.get("/gridpoints/#{p.id}/#{p.x},#{p.y}/forecast/hourly")
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def valid_point?
    !context.point.nil?
  end
end
