class GymsController < ApplicationController
    def create
        set_gyms
        filter_gyms params_gym
        @gym_containers_html = render_to_string action: :create, formats: :html, layout: false        
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
            
            if parameters[:day_period].nil?
                filtered_gyms.append(g)
                next
            end
            
            if parameters[:day_period] == 'morning'
                start_time = 6
                end_time = 12
            elsif parameters[:day_period] == 'afternoon'
                start_time = 12
                end_time = 18
            elsif parameters[:day_period] == 'evening'
                start_time = 18
                end_time = 23
            end

            g.schedules.each do |schedule|
                next if !schedule.hour.include?('às')
                g_start_time = schedule.hour[0..1].to_i
                g_end_time = schedule.hour[-3..-2].to_i
                if((g_start_time <= start_time && start_time < g_end_time) ||
                   (g_start_time < end_time && end_time <= g_end_time))
                    filtered_gyms.append(g)
                    break
                end
            end
        end
        @gyms = filtered_gyms
    end
end