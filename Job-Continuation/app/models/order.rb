class Order < ApplicationRecord
  belongs_to :customer

  validates :status, presence: true, inclusion: { in: %w[pending processing processed failed] }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :processed, -> { where(status: "processed") }
  scope :failed, -> { where(status: "failed") }
  scope :unprocessed, -> { where(processed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_processing!
    update!(status: "processing")
  end

  def mark_as_processed!
    update!(status: "processed", processed_at: Time.current)
  end

  def mark_as_failed!
    update!(status: "failed")
  end
end
