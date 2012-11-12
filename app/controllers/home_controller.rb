class HomeController < ApplicationController

  def index
    flash.now[:notice] = "Welcome!"
  end

end
