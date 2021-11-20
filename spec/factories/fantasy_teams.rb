# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_team do
    name { 'Bears United' }
    association :user

    trait :completed do
      completed { true }
    end
  end
end