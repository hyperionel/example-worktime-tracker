# frozen_string_literal: true

class ReportsController < ApplicationController
  def get
    report = Report.new(report_params)

    if report.valid?
      render json: report.generate, status: :ok
    else
      render json: { error: 'Error generating report' }, status: :bad_request
    end
  end

  def report_params
    params.permit(:employee_id, :from, :to)
  end
end
