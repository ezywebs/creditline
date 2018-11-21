module Api
  module V1
    class CollectorController < ApplicationController
      def_param_group :collector_response do
        property :interest, Float, :desc => "Interest($) that will be charge after 30 day period"
        property :balance, Float, :desc => "Current outstanding balance on the credit line"
        property :credit_line, Hash, :desc => "Credit line" do
          property :id, Integer, :desc => "ID of credit line"
          property :limit, Float, :desc => "Limit of credit line"
          property :apr, Float, :desc => "APR (interest %)"
          property :available, Float, :desc => "Available money to draw"
          property :last_statement, Date, :desc => "Date of last statement"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, Date, :desc => "Date of creation"
        end
          property :transactions, Hash, :desc => "List of all transactions for the period" do
          property :id, Integer, :desc => "ID of transaction"
          property :amount, Float, :desc => "Transaction amount (draws are positive and payments - negative)"
          property :credit_line_id, Integer, :desc => "ID of credit line"
          property :date_adjust, Integer, :desc => "Adjusted date created in days (e.g. 30 for 1 month in future, or -30 for 1 month in the past)"
          property :created_at, Date, :desc => "Date of creation"
        end
      end
      
      api :GET, "/collector/charge/:id", "Charge an interest on the credit line for 30 day period"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :collector_response
        end
      end
      def charge
        data = calculate_interest(params[:id])
        CreditLine.find(params[:id]).update(:last_statement => data[:statement_ending] + 1.days, :available => data[:credit_line][:available] - data[:interest])
        render json: {status: "SUCCESS", message: "Charge interest", data: data}, status: :ok
      end
      
      api :GET, "/collector/:id", "View statement of the credit line including balance and interest for 30 day period"
      returns :code => 200, :desc => "a successful response" do
        property :data, Hash, :desc => "An object" do
          param_group :collector_response
        end
      end
      def view
        data = calculate_interest(params[:id])
        render json: {status: "SUCCESS", message: "View statement", data: data}, status: :ok
      end

      private
      def calculate_interest(id)
        credit_line = CreditLine.find(id)
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

        if transactions.count.eql?(0) and balance >= 0
          balance = credit_line.limit - credit_line.available
          interest =  balance * (credit_line.apr / 100) / 365 * 30
        else 
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
        end
        
        { interest: interest.round(2), balance: balance, credit_line: credit_line, transactions: transactions, statement_ending: statement_ending }
      end
    end
  end
end