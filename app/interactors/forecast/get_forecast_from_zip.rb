class Forecast::GetForecastFromZip
  include Interactor::Organizer

  organize Forecast::FetchCoordinatesFromZip,
    Forecast::FetchPointFromCoordinates,
    Forecast::FetchForecastForPoint
end

