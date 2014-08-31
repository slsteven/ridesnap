class PagesController < ApplicationController

  def about
    @about = true
  end

  def agent
    @agent = true
  end

  def contact
    @contact = true
  end

  def faq
    @faq = true
  end

  def home
    @home = true
  end

  def start
    @start = true
    Settings.vehicle_makes.to_hash.each_with_object(@makes=[]) do |(k,v),o|
      o << [v,k]
    end
    @models     = ['blah', 'blah']
    @years      = Date.today.year.downto(1994)
    @trims      = ['swiggity', 'swooty']
    @miles      = ['0-29k', '30k-59k', '60k-89k', '90k-119k', '120k+']
    @conditions = ['excellent', 'very good', 'good', 'fair', 'poor']
  end
end
