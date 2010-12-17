class Auth < Erector::Widget
  def content
    html do
      head do
        link :type => 'text/css', :rel => 'stylesheet', :href => '/web.css'
      end
      body do
        form :class => 'login', :method => 'POST' do
          h2 'Login with your Instagram Creds'

          div :class => 'field' do
            label 'Username', :for => 'username'
            input :type => 'text', :id => 'username', :name => 'username'
          end

          div :class => 'field' do
            label 'Password', :for => 'password'
            input :type => 'password', :id => 'password', :name => 'password'
          end

          input :type => 'submit', :value => 'Login'

          div :class => 'disclaimer' do
            span <<-EOF
              I super promise I'm not logging your Instagram credentials. However,
              if you want to be cautious (you probably should be) the code is open
              source, and you can feel free to run it on your own. Get it here:
            EOF
            a 'github.com/tyler/instagram-web', :href => 'http://github.com/tyler/instagram-web'
          end
        end
      end
    end      
  end
end
