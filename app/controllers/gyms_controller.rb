class GymsController < ApplicationController
    def create
        parameters = params_gym
        set_gyms
        filter_gyms params_gym
        @my_html = render_to_string action: :create, formats: :html, layout: false        
    end

    private
    def params_gym
        params.permit(:day_period, :show_closed_gyms)
    end
    
    def set_gyms
        locations = get_all_locations_from_api
        convert_locations_2_gyms(locations)
    end
    
    def get_all_locations_from_api
        uri = URI('https://test-frontend-developer.s3.amazonaws.com/data/locations.json')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json'})
        response = http.request(request)
        body = JSON.parse(response.body)
        body['locations']
    end

    def convert_locations_2_gyms(locations)
        @gyms = []
        locations.each do |l|
            if l.has_key?('content') && l['content'] != ''
                l['content'] = l['content'][4..-6] #Removing initial "\n<p>" and final "<\p>\n"
                l['content'] = l['content'].gsub('&#8211;', '')
                l['content'], l['state'] = l['content'].split('<br>')
            else
                l['content'] =  [l['street'], l['region'], l['city_name']].join(' ')
                l['state'] = [l['state_name'], l['uf']].join(' ')
            end
            
            schedules = []
            if !l['schedules'].nil? && l['schedules'].size > 0
                l['schedules'].each do |orig_sch|
                    new_sch = Schedule.new(weekdays:orig_sch['weekdays'],
                                           hour:orig_sch['hour'])
                    schedules.append(new_sch)
                end
            end

            if l['locker_room'] == 'allowed'
                l['locker_room'] = 'required'
            elsif l['locker_room'] == 'closed'
                l['locker_room'] = 'forbidden'
            end

            if l['fountain'] == 'not_allowed'
                l['fountain'] = 'forbidden'
            end

            g = Gym.new(name:l['title'],
                        address:l['content'],
                        state:l['state'],
                        opened:l['opened'],
                        mask:l['mask'],
                        towel:l['towel'],
                        fountain:l['fountain'],
                        locker_room:l['locker_room'],
                        schedules: schedules)
            @gyms.append(g)
        end
    end

    def filter_gyms(parameters)
        filtered_gyms = []
        @gyms.each do |g|
            next if parameters[:show_closed_gyms].nil? and !g.opened
            filtered_gyms.append(g)
        end
        @gyms = filtered_gyms
    end
end