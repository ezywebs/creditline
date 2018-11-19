class WelcomeController < ApplicationController
  def index
    credit_lines = HTTParty.get('https://creditline-eng80lvl.c9users.io/api/v1/credit_lines')
  end
end