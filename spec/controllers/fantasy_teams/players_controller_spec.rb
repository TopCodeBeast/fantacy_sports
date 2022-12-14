# frozen_string_literal: true

describe FantasyTeams::PlayersController, type: :controller do
  describe 'GET#index' do
    it_behaves_like 'required auth'
    it_behaves_like 'required email confirmation'

    context 'for logged users' do
      sign_in_user

      context 'for not existing fantasy team' do
        it 'returns json not_found status with errors' do
          do_request

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of another user' do
        let!(:fantasy_team) { create :fantasy_team }

        it 'returns json not_found status with errors' do
          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }

          expect(response).to have_http_status :not_found
        end
      end

      context 'for existing fantasy team of user' do
        let!(:fantasy_team) { create :fantasy_team, user: @current_user }

        before do
          create :fantasy_teams_player, fantasy_team: fantasy_team

          get :index, params: { fantasy_team_id: fantasy_team.uuid, locale: 'en' }
        end

        it 'returns status 200' do
          expect(response).to have_http_status :ok
        end

        %w[uuid price player team].each do |attr|
          it "response contains teams player #{attr}" do
            expect(response.body).to have_json_path("teams_players/data/0/attributes/#{attr}")
          end
        end

        %w[points statistic].each do |attr|
          it "response contains player #{attr}" do
            expect(response.body).to have_json_path("teams_players/data/0/attributes/player/#{attr}")
          end
        end
      end
    end

    def do_request
      get :index, params: { fantasy_team_id: 'unexisting', locale: 'en' }
    end
  end
end
