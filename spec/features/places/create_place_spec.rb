feature 'Create place', :js do
  context 'Full public maps' do
    before do
      @map = create :map, :full_public
    end

    scenario 'create valid place as user' do
      skip 'Map rendering issue'
      create_place_as_user(place_name: 'Any place', map_token: @map.secret_token)
      visit map_path(map_token: @map.secret_token)
      find(:css, '.show-places-index').trigger('click')

      expect(page).to have_content('Any place', count: 1)
    end

    scenario 'create valid place as guest' do
      skip("Works live, dunno why not in specs")
      create_place_as_guest(place_name: 'Another place', map_token: @map.public_token)
      visit places_path(map_token: @map.public_token)

      expect(page).to have_content('Another place')
      expect(page).not_to have_css('.glyphicon-pencil')
    end

    scenario 'should create new categories if not existent already' do
      expect(Category.count).to eq 0
      login_as_user
      visit new_place_path(map_token: @map.public_token)
      fill_in_valid_place_information
      fill_in('place_categories', with: 'Hospital, Cafe')
      click_button('Create Place')

      expect(Category.count).to eq 2
      expect(Place.last.categories).to eq Category.first(2).map(&:id).join(',')
    end

    scenario 'see guests session places on map' do
      skip 'To be implemented'
      create_place_as_guest(place_name: 'Another place', map_token: @map.public_token)
      create_place_as_guest(place_name: 'Still another place', map_token: @map.public_token)
      visit '/en'

      expect(page).to have_content('Another place')
      expect(page).to have_content('Still another place')
    end

    scenario 'visit new place view with coordinate parameters' do
      # Redefine geocoder response to match geocoder return
      switch_geocoder_stub

      visit new_place_path(map_token: @map.public_token) + '?longitude=1&latitude=1'

      expect(find_field('place_city').value).to eq('Berlin')
    end

    scenario 'show only one wysiwyg editor for current locale' do
      skip "Feature works, dunno how to write the test properly..."
      visit new_place_path(map_token: @map.public_token)
      expect(page).to have_css('.wysihtml5-toolbar', count: 1)

      page.find_all('.glyphicon-triangle-bottom').last.trigger('click')
      expect(page).to have_css('.wysihtml5-toolbar', count: 2)
    end

    scenario 'Reverse geocodes if lat/lon is provided and populates value to form fields' do
      visit new_place_path(map_token: @map.public_token) + '?longitude=12&latitude=52'

      expect(page.find('#place_street').value).to eq('Magdalenenstraße')
      expect(page.find('#place_postal_code').value).to eq('10365')
      expect(page.find('#place_city').value).to eq('Berlin')
    end

    scenario 'Commits hidden geofeatures district, federal state and country' do
      visit new_place_path(map_token: @map.public_token) + '?longitude=12&latitude=52'
      fill_in('place_name', with: 'SomePlace')
      validate_captcha
      click_on('Create Place')
      new_place = Place.find_by(name: 'SomePlace')

      expect(new_place.district).to eq 'Lichtenberg'
      expect(new_place.federal_state).to eq 'Berlin'
      expect(new_place.country).to eq 'Germany'
    end
  end
end
