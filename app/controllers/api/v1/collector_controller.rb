module Api
  module V1
    class CollectorController < ApplicationController
      def charge
        credit_line = CreditLine.find(params[:id])
        statement_date = credit_line.last_statement
        statement_ending = statement_date + 30.days
        draws = Draw.where(credit_line_id: params[:id], :created_at => statement_date..statement_ending)
        payments = Payment.where(credit_line_id: params[:id], :created_at => statement_date..statement_ending)
        
        # change sign of amount to process all transactions together
        payments.each { |p| p.amount = p.amount * -1}

        # merging all transactions together and sorting by date
        transactions = draws + payments
        transactions.sort_by! &:created_at
      
        interest = 0
        balance = 0

        transactions.each_with_index do |t, i|
          # finding most recent outstanding balance
          balance = balance + t.amount
          
          # finding period for new balance to calculate interest
          transaction_beginning = t.created_at
          transaction_ending = transactions[i+1].nil? ? statement_ending : transactions[i+1].created_at 
          period = (transaction_ending.to_date - transaction_beginning.to_date).round
          
          # calculating interest and adding to previous
          interest = interest + balance * (credit_line.apr / 100) / 365 * period
        end
      
        credit_line.update(:statement_date => statement_ending + 1.days)
      
        render json: {status: "SUCCESS", message: "CollectorController is working", interest: interest.round(2), balance: balance, credit_line: credit_line, transactions: transactions}, status: :ok
      end
      
      def force_charge
        
      end
    end
  end
end