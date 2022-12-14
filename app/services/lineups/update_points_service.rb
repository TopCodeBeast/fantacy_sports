# frozen_string_literal: true

module Lineups
  class UpdatePointsService
    prepend ApplicationService

    def initialize(
      fantasy_teams_update_points_service: FantasyTeams::UpdatePointsService
    )
      @fantasy_teams_update_points_service = fantasy_teams_update_points_service
    end

    def call(lineup_ids:)
      lineups = Lineup.where(id: lineup_ids)
      fantasy_team_ids = []

      lineups.each { |lineup|
        lineup.update(points: lineup.lineups_players.active.pluck(:points).sum(&:to_i))
        fantasy_team_ids.push(lineup.fantasy_team_id)
      }

      @fantasy_teams_update_points_service.call(fantasy_team_ids: fantasy_team_ids.uniq)
    end
  end
end
