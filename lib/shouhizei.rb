require 'shouhizei/version'
require 'yaml'
require 'active_support'
require 'active_support/core_ext'

module Shouhizei
  RoundUp = 'Up'
  RoundDown = 'Down'
  Round = 'Round'

  def self.rate_on(time = Time.current, reduced: false)
    date = time.in_time_zone('Asia/Tokyo').to_date
    rate_list.reverse_each do |key_date, rate|
      rate_key = reduced && rate['reduced'] ? 'reduced' : 'default'

      return rate[rate_key].to_r if date >= key_date
    end
    0.0r
  end

  def self.including(price:, time: Time.current, reduced: false)
    including_price = price + price * rate_on(time, reduced)
    return including_price.round if config[:rounding] == Round
    return including_price.ceil if config[:rounding] == RoundUp
    including_price.floor
  end

  def self.config
    @@config ||= {rounding: RoundDown}
  end

  private

  def self.rate_list
    @@rate_list ||= YAML.load_file(File.expand_path('./../rate_list.yml', __FILE__))
  end
end
