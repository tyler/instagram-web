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
    http = post(AUTH, :username => u, :password => pw, :device_id => '0000')

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
    http = get(TIMELINE)

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
    http = get(NEWS)

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
    http = post(COMMENT[id], :comment_text => text)

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

  def get(url, head={})
    head['User-Agent'] = 'Instagram'
    head[:cookie] = cookie_header if authenticated?
    request = EM::HttpRequest.new(url)
    request.get(:head => head)
  end

  def post(url, body={}, head={})
    head['User-Agent'] = 'Instagram'
    head[:cookie] = cookie_header if authenticated?
    request = EM::HttpRequest.new(url)
    request.post(:head => head, :body => body)
  end

  def parse_response(data)
    JSON.load(data)
  rescue JSON::ParserError
    return 'status' => 'error', 'reason' => 'JSON::ParserError', 'data' => data
  end
end
