
class Forecast::FetchPointFromCoordinates
  include Interactor

  # Expects latitude & longitude in context
  # Sets context point

  WEATHER_HOST = "https://api.weather.gov"

  Point = Struct.new(:id, :x, :y)

  def call
    context.fail!(error: "Missing latitude & longitude") unless valid_coordinates?

    response_json = parse_response(fetch_point)

    p_id = response_json.dig("properties", "gridId")
    px = response_json.dig("properties", "gridX")
    py = response_json.dig("properties", "gridY")
    context.fail!(error: "Incomplete point data") unless [p_id, px, py].all?(&:present?)

    set_point(p_id, px, py)
  end

  private

  def set_point(id, x, y)
    context.point = Point.new(id: id, x: x, y: y)
  end

  def parse_response(response)
    begin
      JSON.parse(response.body)
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def fetch_point
    begin
      conn = Faraday.new(
        url: WEATHER_HOST,
        headers: { "User-Agent" => Rails.application.name }
      )

      conn.get("/points/#{context.latitude},#{context.longitude}")
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def valid_coordinates?
    context.latitude.present? && context.longitude.present?
  end
end
