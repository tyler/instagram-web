require 'yaml'

class Instasite < Sinatra::Base
  get '/' do
    igram = Instagram.new(request.cookies)
    timeline = igram.timeline
    if timeline
      username = request.cookies['ds_user'].split(';')[0]
      Timeline.new({ :user => username }.merge(timeline)).to_html
    else
      Auth.new.to_html
    end
  end

  post '/' do
    success, *cookies = Instagram.new.auth(params['username'], params['password'])

    if success
      request.cookies.each { |k,_| response.delete_cookie(k) }
      cookies.each do |c|
        k, v = c.match(/^(.*?)=(.*)$/).captures
        response.set_cookie k, v
      end
    end

    redirect '/'
  end

  post '/comment' do
    igram = Instagram.new(request.cookies)
    if igram.comment(params['id'].to_i, params['comment'])
      redirect '/'
    else
      halt 500, "Something went quite wrong."
    end
  end

  get '/logout' do
    request.cookies.each { |k,_| response.delete_cookie(k) }
    redirect '/'
  end
end
