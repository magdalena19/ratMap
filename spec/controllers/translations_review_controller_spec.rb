require 'rails_helper'

describe TranslationsReviewController do
  let(:map) { create :map, :full_public }
  let(:new_place) { create :place, :unreviewed, map: map }
  let(:place_with_unreviewed_changes) { create :place, :reviewed, name: 'Magda19', description_en: 'This is a description.', map: map }
  let(:translations) { place_with_unreviewed_changes.translations }
  let(:user) { create :user, name: 'Norbert' }

  before do
    login_as user
    place_with_unreviewed_changes.update_attributes(name: 'Magda', description: 'This is an updated description.')
  end

  context 'GET #review' do
    it 'populates correct map in @map' do
      translation = translations.find_by(description: 'This is an updated description.')
      get :confirm, id: translation.id, map_token: map.secret_token

      expect(assigns(:map)).to be_a(Map)
    end
  end

  context 'GET #confirm' do
    it 'confirms unreviewed translations' do
      translation = translations.find_by(description: 'This is an updated description.')
      get :confirm, id: translation.id, map_token: map.secret_token

      translation.reload
      expect(translation.versions.count).to eq(1)
      expect(translation.description).to eq('This is an updated description.')
    end
  end

  context 'GET #refuse' do
    it 'deletes only unreviewed translation versions' do
      translation = translations.find_by(description: 'This is an updated description.')
      get :refuse, id: translation.id, map_token: map.secret_token

      translation.reload
      expect(translation.versions.count).to eq(1)
      expect(translation.description).to eq('This is a description.')
    end
  end
end
