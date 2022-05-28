# frozen_string_literal: true

module Teams
  module Players
    module Price
      class ChangeService
        prepend ApplicationService

        LIMIT_FOR_SMALL_CHANGE = 0.1
        PRICE_SMALL_CHANGE = 10
        LIMIT_FOR_MEDIUM_CHANGE = 0.3
        PRICE_MEDIUM_CHANGE = 20
        LIMIT_FOR_BIG_CHANGE = 0.6
        PRICE_BIG_CHANGE = 30

        def call(week:)
          @week = week
          Teams::Player.where(id: transfers_data.keys).each do |teams_player|
            teams_player.update!(price_cents: teams_player.price_cents + price_modified(teams_player.id))
          end
        end

        private

        def transfers_data
          @transfers_data ||=
            @week
            .transfers
            .group(:teams_player_id)
            .order('sum_direction desc')
            .sum(:direction)
            .select { |_, value| value.abs >= transfers_limit }
          # example of @transfers_data
          # {14=>100, 8=>46, 18=>44, 23=>39, 3=>39, 9=>38, 22=>34, 13=>20, 12=>12}
        end

        def price_modified(teams_player_id)
          transfers_amount = transfers_data[teams_player_id].abs
          transfers_data[teams_player_id].positive? ? price_change(transfers_amount) : -price_change(transfers_amount)
        end

        def price_change(transfers_amount)
          if transfers_amount >= transfers_amount_for_big_price_change
            PRICE_BIG_CHANGE
          elsif transfers_amount >= transfers_amount_for_medium_price_change
            PRICE_MEDIUM_CHANGE
          elsif transfers_amount >= transfers_amount_for_small_price_change
            PRICE_SMALL_CHANGE
          end
        end

        def transfers_limit
          @week.lineups.size * LIMIT_FOR_SMALL_CHANGE
        end

        def transfers_amount_for_big_price_change
          @transfers_amount_for_big_price_change ||= LIMIT_FOR_BIG_CHANGE * @week.lineups.size
        end

        def transfers_amount_for_medium_price_change
          @transfers_amount_for_medium_price_change ||= LIMIT_FOR_MEDIUM_CHANGE * @week.lineups.size
        end

        def transfers_amount_for_small_price_change
          @transfers_amount_for_small_price_change ||= LIMIT_FOR_SMALL_CHANGE * @week.lineups.size
        end
      end
    end
  end
end