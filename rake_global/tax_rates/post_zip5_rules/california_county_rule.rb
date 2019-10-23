# frozen_string_literal: true

class CaliforniaCountyRule < PostRule
  # https://www.cdtfa.ca.gov/formspubs/cdtfa105.pdf
  # https://github.com/Shopify/taxes/issues/192
  def county_taxes
    @county_taxes ||= {
        'ALAMEDA': 2,
        'AMADOR': 0.5,
        'CONTRA COSTA': 1,
        'DEL NORTE': 0.25,
        'FRESNO': 0.725,
        'HUMBOLDT': 0.5,
        'IMPERIAL': 0.5,
        'INYO': 0.5,
        'LOS ANGELES': 2.25,
        'MADERA': 0.5,
        'MARIN': 1,
        'MARIPOSA': 0.5,
        'MENDOCINO': 0.625,
        'MERCED': 0.5,
        'MONTEREY': 0.5,
        'NAPA': 0.5,
        'NEVADA': 0.25,
        'ORANGE': 0.5,
        'RIVERSIDE': 0.5,
        'SACRAMENTO': 0.5,
        'SAN BENITO': 1,
        'SAN BERNARDINO': 0.5,
        'SAN DIEGO': 0.5,
        'SAN JOAQUIN': 0.5,
        'SAN MATEO': 2,
        'SANTA BARBARA': 0.5,
        'SANTA CLARA': 1.75,
        'SANTA CRUZ': 1.75,
        'SOLANO': 0.125,
        'SONOMA': 1,
        'STANISLAUS': 0.625,
        'TULARE': 0.5,
        'YUBA': 1
      }.with_indifferent_access
    end

  def applicable?(zip5) do
    zip5['STATE_ABBREV'] == 'CA'
  end

  def apply(zip5) do
    county_name = zip5['COUNTY_NAME'].upcase
    return unless county_taxes.key?(county_name)

    total_rate = zip5['TOTAL_SALES_TAX'].to_d

    state_rate = zip5['STATE_SALES_TAX'].to_d
    rolling_rate -= state_rate

    county_rate = county_taxes[county_name]
    other_rates = zip5['OTHER1_SALES_TAX'].to_d +
      zip5['OTHER2_SALES_TAX'].to_d +
      zip5['OTHER3_SALES_TAX'].to_d +
      zip5['OTHER4_SALES_TAX'] +
      zip5['MTA_SALES_TAX'] +
      zip5['SPD_SALES_TAX']

    city_rate = total_rate - (state_rate - county_rate - rolling_rate)

    return if city_rate < 0

    zip5['COUNTY_SALES_TAX'] = county_rate
    zip5['CITY_SALES_TAX'] = city_rate
  end
end
