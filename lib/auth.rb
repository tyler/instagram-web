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

          div <<-EOF, :class => 'disclaimer'
            I super promise I'm not logging your Instagram credentials.
          EOF
        end
      end
    end      
  end
end
