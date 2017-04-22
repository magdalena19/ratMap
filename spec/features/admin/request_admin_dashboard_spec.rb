feature 'Admin dashboard', :js do
  scenario 'it can accesses the dashboard as admin user' do
    login_as_admin
    visit admin_dashboard_path
    expect(page).to have_css('.glyphicon-tasks')
  end

  scenario 'it links to admin dashboard in navbar as admin user' do
    login_as_admin
    page.find_all(:css, '.locale-selection').first.trigger('click')
    page.find('.glyphicon-tasks').trigger('click')
    expect(page).to have_content('Manage users')
    expect(page).to have_content('Global settings')
  end
end
