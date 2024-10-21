class Forecast::FetchForecastForPoint
  include Interactor

  # Expects [grid]point in context
  # Sets context forecast

  FORECAST_HOST = "https://api.weather.gov"
  FORECAST_TIMEOUT = 30.minutes

  ForecastData = Struct.new(:starts_at, :ends_at, :temperature, :short_forecast, :icon, :cached)

  def call
    context.fail!(error: "Missing point") unless valid_point?

    cached = true
    p = context.point
    cache_key = "forecasts:#{p.id}/#{p.x},#{p.y}"
    body = Rails.cache.fetch(cache_key, expires_in: FORECAST_TIMEOUT) do
      cached = false
      fetch_forecast.body
    end

    response_json = parse_response(body)

    current_forecast = response_json.dig("properties", "periods")&.first
    context.fail!(error: "No forecast") unless current_forecast

    starts_at = current_forecast["startTime"]
    ends_at = current_forecast["endTime"]
    temperature = current_forecast["temperature"]
    short_forecast = current_forecast["shortForecast"]
    icon = current_forecast["icon"]

    set_forecast(starts_at, ends_at, temperature, short_forecast, icon, cached)
  end

  private

  def set_forecast(starts_at, ends_at, temperature, short_forecast, icon, cached)
    context.forecast = ForecastData.new(starts_at: starts_at,
                                        ends_at: ends_at,
                                        temperature: temperature,
                                        short_forecast: short_forecast,
                                        icon: icon,
                                        cached: cached)
  end

  def parse_response(body)
    begin
      JSON.parse(body)
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
