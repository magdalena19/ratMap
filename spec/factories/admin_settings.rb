FactoryGirl.define do
  factory :settings, class: 'Admin::Setting' do
    app_title 'SomeApp'
    admin_email_address 'admin@secret.com'
    user_activation_tokens 2
    app_imprint ''
    app_privacy_policy ''
    captcha_system 'recaptcha'
    expiry_days 30
  end
end
