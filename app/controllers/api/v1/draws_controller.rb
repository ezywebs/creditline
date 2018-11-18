module Api
  module V1
    class DrawsController < ApplicationController
      def index
        draws = Draw.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all draws', data: draws}, status: :ok
      end

      def show
        begin
          draw = Draw.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about draw transaction', data: draw}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your draw transaction is not found in our system.'}, status: :unprocessable_entity
        end
      end

      def create
        draw = Draw.new(draw_params)
        if draw.save
          render json: {status: 'SUCCESS', message: 'Draw transaction completed successfully!', data: draw}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Error while creating credit line', data: draw.errors}, status: :unprocessable_entity
        end
      end

      def destroy
        begin
          draw = Draw.find(params[:id])
          draw.destroy
          render json: {status: 'SUCCESS', message: 'Draw transaction was removed successfully', data: draw}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This draw transaction is not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end

      def update
        begin
          draw = Draw.find(params[:id])
          if draw.update_attributes(draw_params)
            render json: {status: 'SUCCESS', message: 'Draw transaction was updated successfully', data: credit_line}, status: :ok
          else
            render json: {status: 'ERROR', message: 'Error while updating draw transaction.', data: credit_line.errors}, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This draw transaction is not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      private
      def draw_params
        params.permit(:amount, :credit_line_id)
      end
    end
  end
end