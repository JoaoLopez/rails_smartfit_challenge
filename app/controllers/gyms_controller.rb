class GymsController < ApplicationController
    def create
        parameters = params_gym
        get_all_gyms
        respond_to do |format|
            format.js
        end
    end

    private
    def params_gym
        params.permit(:day_period, :show_closed_gyms)
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
            print(l)
            print("\n\n")
            if 'content' in l
                l['content'] = l['content'][4..-6] #Removing initial "\n<p>" and final "<\p>\n"
            else
                l['content'] =  [l['street'], l['region'], l['city_name'], l['state_name'], l['uf']].join(' ')
            end
            
            schedules = []
            if !l['schedules'].nil? && l['schedules'].size > 0
                l['schedules'].each do |orig_sch|
                    new_sch = Schedule.new(weekdays:orig_sch['weekdays'],
                                           hour:orig_sch['hour'])
                    schedules.append(new_sch)
                end
            end

            g = Gym.new(name:l['titles'],
                        address:l['content'],
                        opened:l['opened'],
                        mask:l['mask'],
                        towel:l['towel'],
                        fountain:l['fountain'],
                        locker_room:l['locker_room'],
                        schedules: schedules)
            @gyms.append(g)
        end
    end

    def get_all_gyms
        locations = get_all_locations_from_api
        convert_locations_2_gyms(locations)
    end
end