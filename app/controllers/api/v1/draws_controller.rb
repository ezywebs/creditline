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
        
        #verify available balance on the account to make transaction
        if draw.amount > draw.credit_line.available
          return render json: {status: 'ERROR', message: 'Not enough credit limit for this transaction. Try with less amount.', data: draw.errors}, status: :unprocessable_entity
        end
        
        # adjust date created if delay was specified
        draw.created_at = DateTime.now + draw.delay_days.days unless draw.delay_days.nil? or draw.delay_days.eql?(0)
        
        if draw.save
          
          # update available balance of the credit line
          draw.credit_line.update(:available => draw.credit_line.available - draw.amount)
          
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
        params.permit(:amount, :credit_line_id, :delay_days)
      end
    end
  end
end