# frozen_string_literal: true

class TeamsController < ApplicationController
  skip_before_action :authenticate, only: %i[index]
  before_action :find_teams

  def index
    render json: {
      teams: TeamSerializer.new(@teams).serializable_hash
    }, status: :ok
  end

  private

  def find_teams
    @teams = League.find(params[:league_id]).active_season.teams
  end
end