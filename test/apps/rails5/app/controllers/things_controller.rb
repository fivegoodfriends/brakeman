class ThingsController < ApplicationController
  def index
    @things = Things.all
  end
end

