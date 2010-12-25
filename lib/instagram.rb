require 'fiber'

class Instagram
  BASE = 'https://instagr.am/api/v1'
  AUTH = "#{BASE}/accounts/login/"
  TIMELINE = "#{BASE}/feed/timeline/"
  NEWS = "#{BASE}/activity/recent/"
  COMMENT = lambda { |id| "#{BASE}/media/#{id}/comment/" }

  def initialize(cookies={})
    @session_id = cookies['sessionid']
    @ds_user_id = cookies['ds_user_id']
    @ds_user = cookies['ds_user']
  end

  def authenticated?
    @session_id && @ds_user_id && @ds_user
  end

  def cookie_header
    return "sessionid=#{@session_id}; ds_user_id=#{@ds_user_id}; ds_user=#{@ds_user}"
  end

  def auth(u,pw)
    fiber = Fiber.current
    request = EM::HttpRequest.new(AUTH)
    http = request.post(:body => { :username => u, :password => pw, :device_id => '0000' })

    http.callback do
      data = parse_response(http.response)
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

  def timeline
    return false unless authenticated?

    fiber = Fiber.current
    request = EM::HttpRequest.new(TIMELINE)
    http = request.get(:head => { :cookie => cookie_header })

    http.callback do
      data = parse_response(http.response)
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

  def news
    return false unless authenticated?

    fiber = Fiber.current
    request = EM::HttpRequest.new(NEWS)
    http = request.get(:head => { :cookie => cookie_header })

    http.callback do
      data = parse_response(http.response)
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

  def comment(id, text)
    return false unless authenticated?

    fiber = Fiber.current
    request = EM::HttpRequest.new(COMMENT[id])
    http = request.post(:head => { :cookie => cookie_header }, :body => { :comment_text => text })

    http.callback do
      data = parse_response(http.response)
      fiber.resume(data['status'] == 'ok')
    end

    http.errback do
      fiber.resume false
    end

    return Fiber.yield
  end

  private

  def parse_response(data)
    JSON.load(data)
  rescue JSON::ParserError
    return 'status' => 'error', 'reason' => 'JSON::ParserError', 'data' => data
  end
end
