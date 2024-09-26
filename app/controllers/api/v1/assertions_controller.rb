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
        @result = Assertion.build_from_web_crawler(assertion_params)

        if @result.success? && @result.value.save
          ScreenshotJob.call(@result.value.id)

          render json: @result.value, status: :created
        else
          render json: { error: create_errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @assertion = Assertion.find(params[:id])
        @assertion.destroy
        head :no_content
      end

      private

      def create_errors
        @result.failure? ? @result.message : @result.value.errors.full_messages.join(", ")
      end

      def assertion_params
        params.require(:assertion).permit(:url, :text)
      end
    end
  end
end
