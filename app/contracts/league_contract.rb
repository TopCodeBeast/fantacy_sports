# frozen_string_literal: true

class LeagueContract < ApplicationContract
  config.messages.namespace = :league

  params do
    optional(:id)
    required(:name).value(:hash)
    required(:sport_kind).filled(:string)
  end

  rule(:name) do
    if values[:name].values.any?(&:blank?)
      key.failure(:invalid)
    end
  end

  rule(:sport_kind) do
    if Sports.all.keys.exclude?(values[:sport_kind])
      key.failure(:invalid)
    end
  end
end
