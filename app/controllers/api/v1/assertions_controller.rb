module Api
  module V1
    class AssertionsController < ApplicationController
      def index
        @assertions = Assertion.all
        render json: @assertions
      end

      def show
        @assertion = Assertion.find(params[:id])
        render json: @assertion
      end

      def create
        @assertion = Assertion.build_from_web_crawler(assertion_params)
        if @assertion.nil?
          render json: { error: 'Invalid URL' }, status: :unprocessable_entity
        elsif @assertion.save
          render json: @assertion, status: :created
        else
          render json: @assertion.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @assertion = Assertion.find(params[:id])
        @assertion.destroy
        head :no_content
      end

      private

      def assertion_params
        params.require(:assertion).permit(:url, :text)
      end
    end
  end
end
