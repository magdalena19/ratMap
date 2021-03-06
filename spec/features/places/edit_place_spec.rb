feature 'Edit place', :js do
  before do
    @map = create :map, :full_public
    @place = create :place, :reviewed, categories_string: 'Cafe, Playground', map: @map
    create :place, :reviewed, categories_string: 'Flaschenhals, Gehirnzelle', map: @map
  end

  context 'as privileged user' do
    before do
      visit map_path(map_token: @map.secret_token)
      open_edit_place_modal(id: @place.id)
    end

    scenario 'Do valid place update on attributes and categories as user' do
      fill_in('place_name', with: 'CHANGE')
      click_categories(%w(Gehirnzelle Flaschenhals Cafe Playground))
      find('.submit-place-button').trigger('click')
      show_place_details(name: 'CHANGE')

      expect(page.find('.category-names').text).to eq 'Flaschenhals | Gehirnzelle'
    end
  end

  context 'as guest user' do
    before do
      # Introduce changes as guest user
      visit map_path(map_token: @map.public_token)
      open_edit_place_modal(id: @place.id)
      fill_in('place_name', with: 'Some changes')
      click_on('Update Place')
    end

    scenario 'Do valid place update as guest and show in index afterwards as to be reviewed' do
      skip 'MODIFY SPEC: What needs to be done on guest user edit?'

      expect(page).to have_content('Some changes')
      expect(page).to have_css('.glyphicon-eye-open')
    end

    scenario 'Do valid place update as guest and do not show changes within other users session' do
      skip 'MODIFY SPEC: What needs to be done on guest user edit?'
      Capybara.reset_sessions!

      visit map_path(map_token: @map.public_token)
      show_places_list_panel

      expect(page).not_to have_content('SomeOtherName')
      expect(page).to have_content('SomeReviewedPlace')
    end
  end
end
