module Api
  module V1
    class CreditLinesController < ApplicationController
      def index
        credit_lines = CreditLine.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all credit lines', data: credit_lines}, status: :ok
      end
      
      def show
        begin
          credit_line = CreditLine.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about credit line', data: credit_line}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your credit line is not found in our system.'}, status: :unprocessable_entity
        end
      end
      
      def create
        credit_line = CreditLine.new(credit_line_params)
        if credit_line.save
          render json: {status: 'SUCCESS', message: 'Credit line created successfully', data: credit_line}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Error while creating credit line', data: credit_line.errors}, status: :unprocessable_entity
        end
      end
      
      def destroy
        begin
          credit_line = CreditLine.find(params[:id])
          credit_line.destroy
          render json: {status: 'SUCCESS', message: 'Credit line was removed successfully', data: credit_line}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This credit line is not found in our system and can\'t be removed.'}, status: :unprocessable_entity
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
        params.permit(:limit, :balance, :apr)
      end
    end
  end
end
