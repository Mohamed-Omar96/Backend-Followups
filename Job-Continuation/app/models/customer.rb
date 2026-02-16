class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active, -> { where("created_at >= ?", 1.year.ago) }
  scope :recent, -> { order(created_at: :desc) }
end
