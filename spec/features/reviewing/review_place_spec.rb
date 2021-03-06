feature 'Review place', :js do
  before(:each) do
    @map = create :map, :full_public
    @place = create :place, :reviewed, name: 'Some reviewed place', map: @map
  end

  context 'Privileged user' do
    scenario 'user inputs do not have to be reviewed' do
      visit map_path(map_token: @map.secret_token)
      open_edit_place_modal(id: @place.id)
      fill_in('place_name', with: 'USER CHANGE')
      click_on('Update Place')
      visit places_review_index_path(map_token: @map.secret_token)

      expect(page).not_to have_content('USER CHANGE')
    end
  end

  feature 'Guest edits' do
    before do
      # Workaround: "Emulate" user input, otherwise specs fail mysteriously
      PaperTrail.enabled = true
      @place.update_attributes!(name: 'GUEST CHANGE')
      @place.update(reviewed: false)
    end

    scenario 'Can review guest edits properly' do
      shows_guest_edits_in_review_index_and_review_page
    end

    private
    
    def shows_guest_edits_in_review_index_and_review_page
      visit places_review_index_path(map_token: @map.secret_token)
      expect(page).to have_css('td', text: 'Some reviewed place')

      visit review_place_path(id: @place.id, map_token: @map.secret_token)
      expect(page).to have_content('GUEST CHANGE')
    end
  end
end
