module PlaceAuditing
  def new?
    versions.length == 1 && !reviewed
  end

  def reviewed_version
    if versions.length > 1
      versions[1].reify
    elsif reviewed
      self
    end
  end

  def unreviewed_version
    self if versions.length > 1 || new?
  end

  def reviewed_description
    translation = translation_from_current_locale
    if translation.versions.count > 1
      translation.versions[1].reify.description
    else
      translation.reviewed ? translation.description : ''
    end
  end

  def translation_from_current_locale
    translations.find_by(locale: I18n.locale)
  end

  def destroy_all_updates(translation = nil)
    obj = translation ? translation : self
    updates = obj.reload.versions.find_all { |v| v.event == 'update' }
    updates.each(&:destroy)
  end
end
