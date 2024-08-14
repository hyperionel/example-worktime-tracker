# frozen_string_literal: true

class Event < ApplicationRecord
  enum kind: { in: 0, out: 1 }, _default: 'in'

  validates :employee_id, presence: true, numericality: { only_integer: true }

  def unix_timestamp=(timestamp)
    self.timestamp = Time.at(timestamp.to_i).to_datetime
  end
end
