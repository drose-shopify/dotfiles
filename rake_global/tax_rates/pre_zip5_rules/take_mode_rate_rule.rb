# frozen_string_literal: true

# See: https://github.com/Shopify/taxes/issues/1328
# In order to get a more accurate zip5 rate we need to break
# down the zip4s by county then by city according to the zip5 entry
# We attempt to take the `mode` of each rate for all entries
# that we have found.
#
# If no entries exist for a county/city then only use entries with
# the same county as the zip5. If no county matches the zip5 then use
# all available zips to calculate a rate

class TakeModeRateRule < PreRule
  def applicable?(zip5, extended_zips) do
    true
  end

  def apply(zip5, extended_zips) do
    return zip5 if extended_zips.empty?

    rates = {
      state: [],
      county: [],
      city: [],
      other1: [],
      other2: [],
      other3: [],
      other4: [],
    }

    zips_by_county = extended_zips.select do |zip|
      zip['COUNTY_NAME'] == zip5['COUNTY_NAME']
    end

    zips_by_city = zips_by_county.select do |zip|
      zip['CITY_NAME'] == zip5['CITY_NAME']
    end

    zips = if !zips_by_city.empty?
             zips_by_city
          elsif !zips_by_county.empty?
            zips_by_county
          else
            extended_zips
          end

    zips.each do |zip|
      rates[:state] << zip['STATE_SALES_TAX']
      rates[:county] << zip['COUNTY_SALES_TAX']
      rates[:city] << zip['CITY_SALES_TAX']
      rates[:other1] << zip['OTHER1_SALES_TAX']
      rates[:other2] << zip['OTHER2_SALES_TAX']
      rates[:other3] << zip['OTHER3_SALES_TAX']
      rates[:other4] << zip['OTHER4_SALES_TAX']
    end
    new_zip = zip5.dup
    new_zip['STATE_SALES_TAX'] = mode(rates[:state])
    new_zip['COUNTY_SALES_TAX'] = mode(rates[:county])
    new_zip['CITY_SALES_TAX'] = mode(rates[:city])
    new_zip['OTHER1_SALES_TAX'] = mode(rates[:other1])
    new_zip['OTHER2_SALES_TAX'] = mode(rates[:other2])
    new_zip['OTHER3_SALES_TAX'] = mode(rates[:other3])
    new_zip['OTHER4_SALES_TAX'] = mode(rates[:other4])

    new_zip
  end

  private

  def unincoporated?(zip)
    zip['CITY_NAME'] =~ /UNINCORPORATED/i
  end

  def mode(arr)
    freq = frequency(arr)
    arr.max_by { |v| freq[v] }
  end

  def frequency(arr)
    arr.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
  end

end
