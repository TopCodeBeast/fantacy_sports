# frozen_string_literal: true

class TeamsController < ApplicationController
  skip_before_action :authenticate, only: %i[index]
  skip_before_action :check_email_confirmation, only: %i[index]
  before_action :find_teams

  def index
    render json: {
      teams: TeamSerializer.new(@teams).serializable_hash
    }, status: :ok
  end

  private

  def find_teams
    @teams = Season.active.find_by!(uuid: params[:season_uuid]).teams
  end
end
