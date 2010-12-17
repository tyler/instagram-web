class Timeline < Erector::Widget
  def content
    html do
      head do
        link :type => 'text/css', :rel => 'stylesheet', :href => '/web.css'
      end
      body do
        div :id => 'timeline' do
          div :class => 'controls' do
            span @user, :class => 'username'
            a 'Logout', :href => '/logout'
          end
          
          @items.each do |item|
            div :class => 'item' do
              div :class => 'meta' do
                div :class => 'user' do
                  img :src => item['user']['profile_pic_url'], :class => 'profilepic'
                  span item['user']['full_name'], :class => 'username'
                end
              
                span Time.at(item['taken_at']).strftime('%I:%M%p %m/%d/%Y'), :class => 'taken_at'
              end

              div :class => 'image' do
                a :href => item['image_versions'].last['url'] do
                  img :src => item['image_versions'][1]['url']
                end
              end
            end
          end
        end
      end
    end
  end
end
