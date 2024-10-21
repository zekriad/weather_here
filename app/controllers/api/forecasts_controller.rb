class Api::ForecastsController < ApplicationController
  def zip
    ctx = Forecast::GetForecastFromZip.call(zip: params[:zip])
    if ctx.error
      render json: { error: ctx.error }
    else
      @forecast = ctx.forecast
    end
  end

  def address
    match = params[:address].strip.match(/\d\d\d\d\d$/) # 5 digits at end of string
    zip = match && match[0]
    ctx = Forecast::GetForecastFromZip.call(zip: zip)
    if ctx.error
      render json: { error: ctx.error }
    else
      @forecast = ctx.forecast
    end
  end
end

