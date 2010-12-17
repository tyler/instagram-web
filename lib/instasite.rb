class Instasite < Sinatra::Base
  get '/' do
    if request.cookies['sessionid'] && request.cookies['ds_user_id'] && request.cookies['ds_user']
      curl = Curl::Easy.new('https://instagr.am/api/v1/feed/timeline/')
      curl.cookies = %w(sessionid ds_user_id ds_user).map { |k|
        "#{k}=#{request.cookies[k]}"
      }.join('; ')
      curl.http_get

      timeline = JSON.load(curl.body_str)
      username = request.cookies['ds_user'].split(';')[0]

      Timeline.new({ :user => username }.merge(timeline)).to_html
    else
      Auth.new.to_html
    end
  end

  post '/' do
    fields = {
      'username' => params['username'],
      'password' => params['password'],
      'device_id' => '0000'
    }.map { |k,v| Curl::PostField.content(k,v) }

    curl = Curl::Easy.new('https://instagr.am/api/v1/accounts/login/')
    curl.http_post(*fields)

    body = JSON.load(curl.body_str)

    if body['status'] == 'ok'
      request.cookies.each { |k,_| response.delete_cookie(k) }

      curl.header_str.split("\r\n").grep(/^Set-Cookie:/).each do |l|
        k, v = l.match(/^Set-Cookie: (.*?)=(.*)$/).captures
        response.set_cookie k, v
      end
    end

    redirect '/'
  end

  get '/logout' do
    request.cookies.each { |k,_| response.delete_cookie(k) }
    redirect '/'
  end
end
