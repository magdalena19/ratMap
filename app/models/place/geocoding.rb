module PlaceGeocoding
  def address_changed?
    street_changed? || city_changed? || house_number_changed? || postal_code_changed?
  end

  def lat_lon_present?
    latitude.present? && longitude.present?
  end

  def geocode_with_nodes
    results = Geocoder.search(address).map { |res| OpenStruct.new(res.data) }
    unless results.any?
      errors.add(:address, :address_not_found)
      return false
    end
    node_geoms = results.select { |result| result.type == 'node' }
    other_geoms = results - node_geoms
    @geoms = node_geoms.any? ? node_geoms.first : other_geoms.first
    @geoms = PlaceGeocoding.prepare(search_results: @geoms)
    update_geofeatures_if_missing
  end

  def self.prepare(search_results:)
    # Prepare results
    search_results = OpenStruct.new search_results
    {
      latitude: search_results.lat,
      longitude: search_results.lon,
      house_number: search_results.house_number || (search_results.address['house_number'] if search_results.address),
      street: search_results.street || search_results.road || (search_results.address['street'] || search_results.address['road'] if search_results.address),
      postal_code: search_results.postcode || (search_results.address['postcode'] if search_results.address),
      district: search_results.city_district || search_results.suburb || search_results.district || (search_results.address['city_district'] || search_results.address['suburb '] || search_results.address['district'] if search_results.address),
      city: search_results.city || search_results.town || search_results.village || (search_results.address['city'] || search_results.address['town'] || search_results.address['village'] if search_results.address),
      federal_state: search_results.state || (search_results.address['state'] || search_results.address['county'] if search_results.address),
      country: search_results.country || (search_results.address['country'] if search_results.address)
    }
  end

  def update_geofeatures_if_missing
    @geoms.each do |geo_feature, value|
      self.send("#{geo_feature}=", value) unless self.send("#{geo_feature}").present?
    end
  end
end
