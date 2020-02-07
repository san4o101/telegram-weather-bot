class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  require 'open_weather'

  def start!(*)
    respond_with :message, text: t('.content')
  end

  def help!(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    unless message['location'].present?
      return respond_with :message, text: t('.enter_location')
    end

    location_hash = message['location']
    latitude = location_hash['latitude']
    longitude = location_hash['longitude']
    options = { units: 'metric', APPID: '77951f8731bb7c2327ec2ddd958625e0' }
    weather = OpenWeather::Current.geocode(latitude, longitude, options)
    mess = change_message(weather)
    respond_with :message, text: t('.content', country_code: mess[:emoji_country],
                                                    country_name: mess[:country_name],
                                                    wind_speed: mess[:wind_speed],
                                                    wind_deg: mess[:wind_deg],
                                                    weather_main: mess[:weather_main],
                                                    weather_description: mess[:weather_description],
                                                     temp: mess[:temp],
                                                     temp_max: mess[:temp_max],
                                                     temp_min: mess[:temp_min])
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
        text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    else
      respond_with :message, text: t('telegram_webhooks.action_missing.feature', action: action)
    end
  end

  def change_message(weather_info)
    result = {}
    result[:emoji_country] = EmojiFlag.new(change_flag_name(weather_info['sys']['country']))
    result[:country_name] = weather_info['name']

    wind = weather_info['wind']
    result[:wind_speed] = wind['speed']
    result[:wind_deg] = wind['deg']

    weather = weather_info['weather'][0]
    result[:weather_main] = weather['main']
    result[:weather_description] = weather['description']

    temperature = weather_info['main']
    result[:temp] = temperature['temp']
    result[:temp_max] = temperature['temp_max']
    result[:temp_min] = temperature['temp_min']

    result
  end

  def change_flag_name(country)
    'uk' if country == 'UA'
  end

end
