class CountiesController < ApplicationController
  def index
    counties = LocationData::Counties.for_state(params[:state])

    render json: counties.map { |key, data|
      {key: key, name: data[:name], phone: data[:phone]}
    }
  end
end
