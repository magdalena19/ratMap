feature 'Edit user', :js do
  scenario 'it flashes warning if passwords do not match' do
    login_as_user
    user = User.first
    visit edit_user_path(id: user.id)

    fill_in('user_password', with: 'secret')
    fill_in('user_password_confirmation', with: 'notsecret')
    click_on('Update credentials')

    expect(page).to have_css('.alert-danger')
  end

  scenario 'it displays redeemed tokens properly' do
    login_as_user
    user = User.first
    user.activation_tokens.first.invalidate
    visit edit_user_path(id: user.id)

    expect(page).to have_css('.alert-success', count: 1)
    expect(page).to have_css('.alert-danger', count: 1)
    expect(page).to have_css('.redeem_date', count: 1)
  end

  scenario 'it displays proper message if no user activation tokens are set in admin settings' do
    create :settings, user_activation_tokens: 0
    login_as_user
    user = User.first
    visit edit_user_path(id: user.id)

    expect(page).not_to have_css('.alert')
    expect(page).to have_content('No Activation Tokens')
  end
end
