class PagesController < ApplicationController

  def about
  end

  def contact
  end

  def faq
  end

  def home
  end

  def how
  end

  def start
    @years = Date.today.year.downto(1994)
    @makes = ['honda', 'ford', 'dodge']
    @models = ['blah', 'blah']
    @trims = ['swiggity', 'swooty']
    @miles = ['0-29k', '30k-59k', '60k-89k', '90k-119k', '120k+']
    @conditions = ['excellent', 'very good', 'good', 'fair', 'poor']
  end

end
