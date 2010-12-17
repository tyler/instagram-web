require 'fiber'

class Instagram
  BASE = 'https://instagr.am/api/v1'
  AUTH = "#{BASE}/accounts/login/"
  TIMELINE = "#{BASE}/feed/timeline/"

  def auth(u,pw)
    fiber = Fiber.current
    request = EM::HttpRequest.new(AUTH)
    http = request.post(:body => { :username => u, :password => pw, :device_id => '0000' })

    http.callback do
      data = JSON.load(http.response)
      if data['status'] == 'ok'
        fiber.resume([true, *http.response_header.cookie])
      else
        fiber.resume([false])
      end
    end

    http.errback do
      fiber.resume([false])
    end

    return Fiber.yield
  end

  def timeline(cookies)
    return false unless cookies['sessionid'] && cookies['ds_user_id'] && cookies['ds_user']

    fiber = Fiber.current
    request = EM::HttpRequest.new(TIMELINE)
    cookie_str = %w(sessionid ds_user_id ds_user).map { |k| "#{k}=#{cookies[k]}" }.join('; ')
    http = request.get(:head => { :cookie => cookie_str })

    http.callback do
      data = JSON.load(http.response)
      if data['status'] == 'ok'
        fiber.resume data
      else
        puts "Error!"
        p data

        fiber.resume false
      end
    end

    http.errback do
      puts "Error!"

      p http.response_header.status
      p http.response_header
      p http.response
      p http.error

      fiber.resume false
    end

    return Fiber.yield
  end
end
