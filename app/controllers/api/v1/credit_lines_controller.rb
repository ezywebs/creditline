module Api
    module V1
        class CreditLinesController < ApplicationController
            def index
                credit_lines = CreditLine.order('created_at DESC')
                render json: {status: 'SUCCESS', message: 'List of all credit lines', data: credit_lines}, status: :ok
            end
            
            def show
                credit_line = CreditLine.find(params[:id])
                render json: {status: 'SUCCESS', message: 'Information about credit line', data: credit_line}, status: :ok
            end
            
            def create
                credit_line = CreditLine.new(credit_line_params)
                if credit_line.save
                    render json: {status: 'SUCCESS', message: 'Article saved successfully', data: credit_line}, status: :ok
                else
                    render json: {status: 'ERROR', message: 'Error while saving article', data: credit_line.errors}, status: :unprocessable_entity
                end
            end
            
            private
            def credit_line_params
                params.permit(:limit, :balance, :apr)
            end
        end
    end
end
