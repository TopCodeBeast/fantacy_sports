# frozen_string_literal: true

module FantasyTeams
  module Players
    class TransfersValidator < ApplicationValidator
      BUDGET_LIMIT_CENTS = 10_000

      def call(fantasy_team:, teams_players_ids:, budget_limit: BUDGET_LIMIT_CENTS)
        @fantasy_team     = fantasy_team
        @season           = @fantasy_team.fantasy_leagues.first.season
        @max_team_players = Sports.sport(@fantasy_team.sport_kind)['max_team_players']
        @teams_players    = @season.active_teams_players.where(id: teams_players_ids).includes(:player, :seasons_team)

        initialize_counters
        collect_data
        validate_players_positions
        validate_players_teams
        validate_players_price(budget_limit)

        @errors
      end

      private

      def initialize_counters
        @errors            = []
        @position_kinds    = []
        @team_ids          = []
        @total_price_cents = 0
      end

      def collect_data
        @teams_players.each do |teams_player|
          @position_kinds.push(teams_player.player.position_kind)
          @team_ids.push(teams_player.seasons_team.team_id)
          @total_price_cents += teams_player.price_cents
        end
      end

      def validate_players_positions
        Sports.positions_for_sport(@fantasy_team.sport_kind).each do |position_kind, values|
          next if @position_kinds.count(position_kind) == values['total_amount']

          @errors.push("Invalid players amount at position #{values['name']['en']}")
        end
      end

      def validate_players_teams
        @team_ids
          .each_with_object(Hash.new(0)) { |id, acc| acc[id] += 1 }
          .each { |key, value|
            next if value <= @max_team_players

            @errors.push("Too many players from team #{Team.find(key).name['en']}")
          }
      end

      def validate_players_price(budget_limit)
        return if @total_price_cents <= budget_limit

        @errors.push("Fantasy team's price is too high")
      end
    end
  end
end
