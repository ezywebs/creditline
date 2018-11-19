module Api
  module V1
    class PaymentsController < ApplicationController
      def index
        payments = Payment.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all payments', data: payments}, status: :ok
      end
      
      def show
        begin
          payment = Payment.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about payment transaction', data: payment}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your payment transaction is not found in our system.'}, status: :unprocessable_entity
        end
      end
      
      def create
        payment = Payment.new(payment_params)
        credit_line = payment.credit_line

        if credit_line.available >= credit_line.limit
          return render json: {status: 'ERROR', message: 'Your account is up to date. No payment is needed at this time.'}, status: :unprocessable_entity
        end

        # adjust date created if delay was specified
        payment.created_at = DateTime.now + payment.date_adjust.days unless payment.date_adjust.nil? or payment.date_adjust.eql?(0)
        
        if payment.save
          # check if payment doesn't exceed balance
          if payment.amount > credit_line.limit - credit_line.available
            credit_line.available = credit_line.limit
          else
            credit_line.available = credit_line.available + payment.amount
          end
          
          # update available balance of the credit line
          credit_line.update(:available => credit_line.available)
          
          render json: {status: 'SUCCESS', message: 'Payment transaction completed successfully!', data: payment}, status: :ok
        else
          render json: {status: 'ERROR', message: 'Error while processing payment.', data: payment.errors}, status: :unprocessable_entity
        end
      end
      
      def destroy
        begin
          payment = Payment.find(params[:id])
          payment.destroy
          render json: {status: 'SUCCESS', message: 'Payment transaction was removed successfully', data: payment}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This payment transaction was not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      def update
        begin
          payment = Payment.find(params[:id])
          if payment.update_attributes(payment_params)
            render json: {status: 'SUCCESS', message: 'Payment transaction was updated successfully', data: payment}, status: :ok
          else
            render json: {status: 'ERROR', message: 'Error while updating payment transaction.', data: payment.errors}, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This payment transaction was not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      private
      def payment_params
        params.permit(:amount, :credit_line_id, :date_adjust)
      end
    end
  end
end