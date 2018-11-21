module Api
  module V1
    class CreditLinesController < ApplicationController

      api :GET, "/credit_lines", "Get list of all credit lines"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          property :id, Integer, :desc => "ID of new credit line"
          property :limit, Float, :desc => "Limit of credit line"
          property :apr, Float, :desc => "APR (interest %)"
          property :available, Float, :desc => "Available money to draw"
          property :last_statement, Date, :desc => "Date of last statement"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, String, :desc => "Date of creation"
        end
      end
      def index
        credit_lines = CreditLine.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all credit lines', data: credit_lines}, status: :ok
      end
      
      api :GET, "/credit_lines/:id", "View Credit Line "
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          property :id, Integer, :desc => "ID of new credit line"
          property :limit, Float, :desc => "Limit of credit line"
          property :apr, Float, :desc => "APR (interest %)"
          property :available, Float, :desc => "Available money to draw"
          property :last_statement, Date, :desc => "Date of last statement"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, String, :desc => "Date of creation"
        end
      end
      def show
        begin
          credit_line = CreditLine.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about credit line', data: credit_line}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your credit line is not found in our system.'}, status: :unprocessable_entity
        end
      end
      
      api :POST, "/credit_lines", "Create new credit line"
      param :limit, Float, :desc => "Limit of credit line", :required => true
      param :apr, Float, :desc => "APR (interest %)", :required => true
      param :date_adjust, Integer, :desc => "Adjust the date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          property :id, Integer, :desc => "ID of new credit line"
          property :limit, Float, :desc => "Limit of credit line"
          property :apr, Float, :desc => "APR (interest %)"
          property :available, Float, :desc => "Available money to draw"
          property :last_statement, Date, :desc => "Date of last statement"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, String, :desc => "Date of creation"
        end
      end
      def create
        credit_line = CreditLine.new(credit_line_params)
        
        # adjust date created if adjustment was specified
        if credit_line.date_adjust.nil? or credit_line.date_adjust.eql?(0)
          credit_line.last_statement = DateTime.now
        else
          credit_line.last_statement = DateTime.now + credit_line.date_adjust.days
        end
        
        if credit_line.available.nil? or credit_line.available.eql?(0)
          credit_line.available = credit_line.limit
        end
        
        if credit_line.save
          render json: {status: 'SUCCESS', message: 'Credit line created successfully', data: credit_line}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Error while creating credit line', data: credit_line.errors}, status: :unprocessable_entity
        end
      end
      
      api :DELETE, "/credit_lines/:id", "Delete Credit Line"
      returns :code => 200, :desc => "a successful response"
      def destroy
        begin
          credit_line = CreditLine.find(params[:id])
          credit_line.destroy
          render json: {status: 'SUCCESS', message: 'Credit line was removed successfully', data: credit_line}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This credit line is not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      api :POST, "/credit_lines/:id", "Update credit line"
      param :limit, Float, :desc => "Limit of credit line", :required => true
      param :apr, Float, :desc => "APR (interest %)", :required => true
      param :date_adjust, Integer, :desc => "Adjust the date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          property :id, Integer, :desc => "ID of new credit line"
          property :limit, Float, :desc => "Limit of credit line"
          property :apr, Float, :desc => "APR (interest %)"
          property :available, Float, :desc => "Available money to draw"
          property :last_statement, Date, :desc => "Date of last statement"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, String, :desc => "Date of creation"
        end
      end
      def update
        begin
          credit_line = CreditLine.find(params[:id])
          if credit_line.update_attributes(credit_line_params)
            render json: {status: 'SUCCESS', message: 'Credit line was updated successfully', data: credit_line}, status: :ok
          else
            render json: {status: 'ERROR', message: 'Error while updating credit line.', data: credit_line.errors}, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This credit line is not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      private
      def credit_line_params
        params.permit(:limit, :balance, :apr, :available, :date_adjust, :last_statement)
      end
    end
  end
end
