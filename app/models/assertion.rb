class Assertion < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true
  validates :status, presence: true
  validates :links_number, numericality: { only_integer: true }
  validates :images_number, numericality: { only_integer: true }
end
