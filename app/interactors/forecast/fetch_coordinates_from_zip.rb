class Forecast::FetchCoordinatesFromZip
  include Interactor

  # Expects a zip in context
  # Sets context latitude & longitude

  ZIP_LOOKUP_HOST = "https://api.zippopotam.us"

  def call
    context.fail!(error: "Invalid zip") unless valid_zip?

    response_json = parse_response(fetch_coords)

    closest_place = response_json["places"]&.first
    context.fail!(error: "No known place") unless closest_place

    set_coords(closest_place)
  end

  private

  def set_coords(place)
    context.fail!(error: "No/Invalid coordinates") unless place["latitude"].present? && place["longitude"].present?

    context.latitude = place["latitude"]
    context.longitude = place["longitude"]
  end

  def parse_response(response)
    begin
      JSON.parse(response.body)
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def fetch_coords
    begin
      Faraday.get("#{ZIP_LOOKUP_HOST}/us/#{context.zip}")
    rescue StandardError => e
      context.fail!(error: e)
    end
  end

  def valid_zip?
    context.zip.strip!
    context.zip =~ /^\d\d\d\d\d$/ # 5 digits
  end
end

