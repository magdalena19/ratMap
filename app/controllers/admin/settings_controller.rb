class Admin::SettingsController < ApplicationController
  before_action -> { redirect_to root_path unless @current_user.admin? }
  before_action :init_settings, only: [:edit, :update]

  def edit
    @settings_hash = Admin::Setting.all_settings
  end

  def update
    if @settings.update_attributes(settings_params)
      flash[:success] = t('.success')
      redirect_to admin_settings_url
    else
      flash[:success] = t('.errors')
      render :edit
    end
  end

  private

  def settings_params
    params.require(:admin_setting).permit(:auto_translate, :is_private, :app_title, :maintainer_email_address)
  end

  def init_settings
    @settings = Admin::Setting.last || Admin::Setting.create
  end
end
