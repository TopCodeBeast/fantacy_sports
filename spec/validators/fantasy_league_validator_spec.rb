# frozen_string_literal: true

describe FantasyLeagueValidator, type: :service do
  subject(:validator_call) { described_class.call(params: params) }

  context 'for invalid params' do
    let(:params) { { name: '' } }

    it 'result contains error' do
      expect(validator_call.first).to eq("Name can't be blank")
    end
  end

  context 'for valid params' do
    let(:params) { { name: 'My league' } }

    it 'result does not contain errors' do
      expect(validator_call.size.zero?).to be_truthy
    end
  end
end
