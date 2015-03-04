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

  def buy
    @menu = 'buy'
  end

end
