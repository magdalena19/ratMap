class ReviewController < ApplicationController
  before_action :require_login

  def review_index
    unreviewed_places = Place.all.find_all(&:unreviewed_version)
    @places_to_review = unreviewed_places.map { |p| p.reviewed_version || p.unreviewed_version }
    @unreviewed_translations = all_unreviewed_translations
  end

  def review_place
    @place = Place.find(params[:id])
    @reviewed_place = @place.reviewed_version
    @unreviewed_place = @place.unreviewed_version
  end

  def confirm_place
    p = Place.find(params[:id])
    if p.update(reviewed: true) && destroy_all_updates(p)
      flash.now[:success] = 'Changes confirmed!'
    end
    redirect_to action: 'review_index'
  end

  def refuse_place
    place = Place.find(params[:id])
    if place.new? && place.destroy
      flash[:success] = 'Point refused!'
    elsif place.versions.last.reify.save && destroy_all_updates(place)
      flash[:success] = 'Changes refused!'
    end
    redirect_to action: 'review_index'
  end

  def review_translation
    @reviewed_translation = reviewed_version(translation(params[:id]))
    @unreviewed_translation = translation(params[:id])
    language = translation(params[:id]).locale
    other_translations = place_from(params[:id]).translations.find_all { |t| t.locale != language }
    @other_translations_reviewed = other_translations.map { |t| reviewed_version(t) }.compact
  end

  def confirm_translation
    t = translation(params[:id])
    if destroy_all_updates(t)
      flash[:success] = 'Translation confirmed!'
    end
    redirect_to action: 'review_index'
  end

  def refuse_translation
    t = translation(params[:id])
    if t.versions.last.reify.save && destroy_all_updates(t)
      flash.now[:success] = 'Translation refused!'
    end
    redirect_to action: 'review_index'
  end

  private

  def translation(id)
    place_from(id).translations.find(id)
  end

  def place_from(id)
    Place.find { |p| p.translations.find_by(id: id) }
  end

  def reviewed_version(t)
    t.versions.length > 1 ? t.versions[1].reify : t
  end

  def destroy_all_updates(obj)
    updates = obj.reload.versions.find_all { |v| v.event == 'update' }
    updates.each(&:destroy)
  end

  def all_unreviewed_translations
    array = []
    Place.all.each do |p|
      array.concat(unreviewed_translations(p))
    end
    array
  end

  def unreviewed_translations(place)
    place.translations.find_all do |t|
      t.versions.length > 1
    end
  end

  def require_login
    unless signed_in?
      flash.now[:danger] = 'Access to this page has been restricted. Please login first!'
      redirect_to login_path
    end
  end
end
