describe PasswordResetController do
  context 'GET #request_password_reset' do
    it 'can request new password' do
      get :request_password_reset
      expect(response).to render_template 'password_reset/request_password_reset'
    end
  end

  context 'POST #create_password_reset' do
    before do
      create :settings
    end

    it 'creates new password reset digest for existing account' do
      user = create :user, email: 'norbert@example.com'
      expect {
        post :create_password_reset, password_reset: { email: 'norbert@example.com' }
      }.to change { user.reload.password_reset_digest }.from(nil).to be_a(String)
      expect(flash[:success]).to match 'has been sent'
    end

    it 'sends password request email on password reset request for existing account' do
      create :user, name: 'Birte', email: 'birte@example.com'
      expect {
        post :create_password_reset, password_reset: { email: 'birte@example.com' }
      }.to change { DeliveryGul.deliveries.count }.by(1)
    end

    it 'does nothing if no account was found to reset password for' do
      post :create_password_reset, password_reset: { email: 'unknown@nowhere.com' }
      expect(flash[:danger]).to eq 'Could not find an account with this email address!'
      expect(response).to render_template 'password_reset/request_password_reset'
    end
  end

  context 'GET #reset_password' do
    let (:user) { create :user, name: 'Norber', email: 'norbert@example.com' }

    it 'allows password reset for valid token' do
      user.create_digest_for(attribute: 'password_reset')
      user.save

      get :reset_password, id: user.id, token: user.password_reset_token
      expect(response).to render_template 'password_reset/password_reset_form'
    end

    it 'alerts and redirect to root url if link is invalid' do
      user.create_digest_for(attribute: 'password_reset')
      user.save

      get :reset_password, id: user.id, token: 'Some invalid token'
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq 'Password reset link invalid!'
    end
#
    it 'does not accept tokens older than 24hrs as valid' do
      user.create_digest_for(attribute: 'password_reset')
      user.password_reset_timestamp = Time.now - 25.hours
      user.save

      get :reset_password, id: user.id, token: user.password_reset_token
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq 'Password reset link invalid!'
    end
  end

  context 'PATCH #set_new_password' do
    before do
      @user = create :user
      @user.create_digest_for(attribute: 'password_reset')
      @user.save
    end

    context 'Authentication' do
      it 'Cannot change password without auth token' do
        patch :set_new_password, id: @user.id, new_password: { password: 'change', password_confirmation: 'change' }

        expect(@user.reload.authenticated?(attribute: 'password', token: 'change')).not_to be true
      end

      it 'Cannot change password with other users auth token' do
        user2 = create :user
        user2.create_digest_for(attribute: 'password_reset')
        user2.save

        patch :set_new_password, id: @user.id, token: user2.password_reset_token, new_password: { password: 'change', password_confirmation: 'change' }

        expect(@user.reload.authenticated?(attribute: 'password', token: 'change')).not_to be true
      end

      it 'Can change password with correct auth token' do
        patch :set_new_password, id: @user.id, token: @user.password_reset_token, new_password: { password: 'change', password_confirmation: 'change' }

        expect(@user.reload.authenticated?(attribute: 'password', token: 'change')).to be true
      end
    end
  end
end
