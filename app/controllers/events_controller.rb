# frozen_string_literal: true

class EventsController < ApplicationController
  def save
    event = Event.new(
      employee_id: event_params[:employee_id],
      kind: event_params[:kind],
      unix_timestamp: event_params[:timestamp]
    )

    if event.save
      render json: { success: 'Event saved' }, status: :ok
    else
      render json: { error: event.errors.full_messages }, status: :bad_request
    end
  end

  def event_params
    params.permit(:employee_id, :timestamp, :kind)
  end
end
