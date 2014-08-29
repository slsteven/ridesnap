class PagesController < ApplicationController

  def about
  end

  def agent
  end

  def contact
  end

  def faq
  end

  def home
  end

  def start
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
