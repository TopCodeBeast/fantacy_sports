# frozen_string_literal: true

module Lineups
  class PlayersController < ApplicationController
    include Maintenable

    before_action :find_lineup, only: %i[show]
    before_action :find_user_lineup, only: %i[update]
    before_action :find_lineup_players, only: %i[show]
    before_action :find_league, only: %i[update]
    before_action :validate_league_maintenance, only: %i[update]

    def show
      render json: {
        lineup_players: Lineups::PlayerSerializer.new(@lineup_players).serializable_hash
      }, status: :ok
    end

    def update
      service_call = Lineups::Players::UpdateService.call(
        lineup: @lineup,
        lineups_players_params: lineups_players_params
      )
      if service_call.success?
        render json: { message: t('controllers.lineups.players.lineup_update') }, status: :ok
      else
        render json: { errors: service_call.errors }, status: :unprocessable_entity
      end
    end

    private

    def find_lineup
      @lineup =
        Lineup
          .joins(:week, fantasy_team: :user)
          .where('weeks.status IN (2, 3) OR users.id = ?', Current.user.id)
          .find_by(uuid: params[:lineup_id])

      page_not_found if @lineup.nil?
    end

    def find_user_lineup
      @lineup = Current.user.lineups.find_by!(uuid: params[:lineup_id])
    end

    def find_lineup_players
      @lineup_players = @lineup.lineups_players.includes(teams_player: [:player, { seasons_team: :team }])
    end

    def find_league
      @league = @lineup.week.league
    end

    def lineups_players_params
      params
        .require(:lineup_players)
        .permit(data: [%i[uuid active change_order status]])
        .to_h[:data]
        .map { |hash|
          hash['active'] = hash['active'] == 'true' || hash['active'] == true
          hash['change_order'] = hash['change_order'].to_i
          hash.symbolize_keys
        }
    end
  end
end
