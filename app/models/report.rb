# frozen_string_literal: true

class Report
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :employee_id, :from, :to

  validates :employee_id, presence: true, numericality: { only_integer: true }
  validates :from, presence: true
  validates :to, presence: true
  validate :valid_date_format

  def generate
    return nil unless valid?

    events = Event.where(employee_id:,
                         timestamp: from_date.beginning_of_day..to_date.end_of_day)
    calculate_report(events)
  end

  private

  def valid_date_format
    errors.add(:from, 'Invalid date format') unless valid_date?(from)
    errors.add(:to, 'Invalid date format') unless valid_date?(to)
  end

  def valid_date?(date_string)
    parsed_date(date_string)
  end

  def from_date
    @from_date ||= parsed_date(from)
  end

  def to_date
    @to_date ||= parsed_date(to)
  end

  def parsed_date(date_string)
    DateTime.parse(date_string)
  rescue StandardError
    false
  end

  def calculate_report(events)
    total_work_time = 0
    problematic_dates = []

    events_by_day = events.group_by { |event| Time.at(event.timestamp).to_date }

    (from_date..to_date).each do |date|
      next unless events_by_day[date]

      day_work_time, is_problematic = calculate_day_work_time(events_by_day[date])
      total_work_time += day_work_time unless is_problematic
      problematic_dates << date if is_problematic
    end

    {
      employee_id: employee_id.to_i,
      from: from_date.strftime('%Y-%m-%d'),
      to: to_date.strftime('%Y-%m-%d'),
      worktime_hrs: (total_work_time / 3600).round(2),
      problematic_dates: problematic_dates.map { |date| date.strftime('%Y-%m-%d') }
    }
  end

  def calculate_day_work_time(day_events)
    total_time = 0
    is_problematic = false
    in_event = nil

    day_events.each do |event|
      if event.kind == 'in'
        in_event = event
      elsif event.kind == 'out'
        if in_event
          total_time += event.timestamp - in_event.timestamp
          in_event = nil
        else
          is_problematic = true
        end
      end
    end

    is_problematic ||= in_event.present?

    [total_time, is_problematic]
  end
end
