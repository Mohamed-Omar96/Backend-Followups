class EmailCampaign < ApplicationRecord
  validates :name, presence: true
  validates :subject, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending in_progress completed failed] }
  validates :total_recipients, presence: true, numericality: { greater_than: 0 }
  validates :sent_count, numericality: { greater_than_or_equal_to: 0 }

  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :recent, -> { order(created_at: :desc) }

  def pending?
    status == "pending"
  end

  def in_progress?
    status == "in_progress"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def mark_as_in_progress!
    update!(status: "in_progress")
  end

  def mark_as_completed!
    update!(status: "completed")
  end

  def mark_as_failed!
    update!(status: "failed")
  end

  def increment_sent_count!(count = 1)
    increment!(:sent_count, count)
  end

  def progress_percentage
    return 0 if total_recipients.zero?
    (sent_count.to_f / total_recipients * 100).round(2)
  end
end
