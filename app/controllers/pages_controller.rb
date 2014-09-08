class PagesController < ApplicationController

  def about
    @menu = 'about'
  end

  def agent
    @menu = 'agent'
  end

  def contact
    @menu = 'contact'
  end

  def faq
    @menu = 'faq'
  end

  def home
    @menu = 'home'
  end

  def how
    @menu = 'how'
    render :home
  end

  def schedule
    @menu = 'start'
  end

  def start
    @menu = 'start'
    Settings.vehicle_makes.to_hash.each_with_object(@makes=[]) do |(k,v),o|
      o << [v,k]
    end
    # @miles      = ['0-29k', '30k-59k', '60k-89k', '90k-119k', '120k+']
    # @conditions = ['excellent', 'very good', 'good', 'fair', 'poor']
  end
end
