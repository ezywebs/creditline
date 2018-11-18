module Api
    module V1
        class CreditLinesController < ApplicationController
            def index
                credit_lines = CreditLine.order('created_at DESC')
                render json: {status: 'SUCCESS', message: 'List of all credit lines', data: credit_lines}, status: :ok
            end
        end
    end
end
