require 'httparty'

class WelcomeController < ApplicationController
  def index
    # response = HTTParty.get('https://creditline-eng80lvl.c9users.io/api/v1/credit_lines')
    
    
    # case response.code
    #   when 200
    #     obj = JSON.parse(response.body)
    #   when 404
    #   obj = "Not found"
    #   when 500...600
    #     puts "ZOMG ERROR #{response.code}"
    # end
  end
end