module Api
  module V1
    class DrawsController < ApplicationController
      def_param_group :draw_response do
        property :id, Integer, :desc => "ID of new credit line"
        property :amount, Float, :desc => "Amount of money to draw"
        property :credit_line_id, Integer, :desc => "ID of credit line from which to draw money"
        property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
        property :created_at, Date, :desc => "Date of creation"
      end
      
      def_param_group :draw_request do
        param :amount, String, :desc => "Amount of money to draw", :required => true
        param :credit_line_id, String, :desc => "ID of credit line from which to draw money", :required => true
        param :date_adjust, String, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
      end
      
      api :GET, "/draws", "List of all draws"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :draw_response
        end
      end
      def index
        draws = Draw.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all draws', data: draws}, status: :ok
      end

      api :GET, "/draws/:id", "View draw details"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :draw_response
        end
      end
      def show
        begin
          draw = Draw.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about draw transaction', data: draw}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your draw transaction is not found in our system.'}, status: :unprocessable_entity
        end
      end

      api :POST, "/draws", "Create new draw"
      param_group :draw_request
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :draw_response
        end
      end
      def create
        draw = Draw.new(draw_params)
        
        #verify available balance on the account to make transaction
        if draw.amount > draw.credit_line.available
          return render json: {status: 'ERROR', message: 'Not enough credit limit for this transaction. Try with less amount.', data: draw.errors}, status: :unprocessable_entity
        end
        
        # adjust date created if adjust was specified
        draw.created_at = DateTime.now + draw.date_adjust.days unless draw.date_adjust.nil? or draw.date_adjust.eql?(0)
        
        if draw.save
          
          # update available balance of the credit line
          draw.credit_line.update(:available => draw.credit_line.available - draw.amount)
          
          render json: {status: 'SUCCESS', message: 'Draw transaction completed successfully!', data: draw}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Error while processing draw transaction.', data: draw.errors}, status: :unprocessable_entity
        end
      end

      api :DELETE, "/draws/:id", "Delete draw transaction"
      returns :code => 200, :desc => "a successful response"
      def destroy
        begin
          draw = Draw.find(params[:id])
          draw.destroy
          render json: {status: 'SUCCESS', message: 'Draw transaction was removed successfully', data: draw}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This draw transaction was not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end


      api :PUT, "/draws/:id", "Update draw transaction"
      param_group :draw_request
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :draw_response
        end
      end
      def update
        begin
          draw = Draw.find(params[:id])
          if draw.update_attributes(draw_params)
            render json: {status: 'SUCCESS', message: 'Draw transaction was updated successfully', data: draw}, status: :ok
          else
            render json: {status: 'ERROR', message: 'Error while updating draw transaction.', data: draw.errors}, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This draw transaction was not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      private
      def draw_params
        params.permit(:amount, :credit_line_id, :date_adjust)
      end
    end
  end
end