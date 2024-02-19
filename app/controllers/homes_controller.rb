class HomesController < ApplicationController
    def index
        @gym = Gym.new
    end
end