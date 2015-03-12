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
    @next_city = City.order(requests: :desc).where.not(available: true).first
    @next_city ||= City.order(requests: :asc).first
  end

  def how
    @menu = 'how'
    render :home
  end

  def schedule
    @menu = 'start'
  end

end
