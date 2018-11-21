module Api
  module V1
    class PaymentsController < ApplicationController
      def_param_group :payment_response do
        property :id, Integer, :desc => "ID of new credit line"
        property :created_at, Date, :desc => "Date of creation"
        param_group :payment_request
      end
      
      def_param_group :payment_request do
        param :amount, Float, :desc => "Payment amount", :required => true
        param :credit_line_id, Integer, :desc => "ID of credit line to apply payment", :required => true
        param :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
      end
      
      api :GET, "/payments", "List of all payments"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :payment_response
        end
      end
      def index
        payments = Payment.order('created_at DESC')
        render json: {status: 'SUCCESS', message: 'List of all payments', data: payments}, status: :ok
      end
      
      api :GET, "/payments/:id", "View payment details"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :payment_response
        end
      end
      def show
        begin
          payment = Payment.find(params[:id])
          render json: {status: 'SUCCESS', message: 'Information about payment transaction', data: payment}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! Your payment transaction is not found in our system.'}, status: :unprocessable_entity
        end
      end
      
      api :POST, "/payments", "Create new payment"
      param_group :payment_request
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :payment_response
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
      
      api :DELETE, "/payments/:id", "Delete payment transaction"
      returns :code => 200, :desc => "a successful response"
      def destroy
        begin
          payment = Payment.find(params[:id])
          payment.destroy
          render json: {status: 'SUCCESS', message: 'Payment transaction was removed successfully', data: payment}, status: :ok
        rescue ActiveRecord::RecordNotFound  
          render json: {status: 'ERROR', message: 'Error! This payment transaction was not found in our system and can\'t be removed.'}, status: :unprocessable_entity
        end
      end
      
      api :PUT, "/payments/:id", "Update payment transaction"
      param_group :payment_request
      formats ['json']
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :payment_response
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