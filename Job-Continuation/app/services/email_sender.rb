# Service to send emails with simulated delivery
# Demonstrates batch email processing for campaigns
class EmailSender
  attr_reader :campaign, :recipient_email

  def initialize(campaign:, recipient_email:)
    @campaign = campaign
    @recipient_email = recipient_email
  end

  # Send a single email
  def send_email!
    Rails.logger.info "Sending email to #{recipient_email} (campaign: #{campaign.name})"

    # Simulate email personalization
    personalize_content

    # Simulate email delivery
    deliver_email

    # Simulate email tracking setup
    setup_tracking

    Rails.logger.debug "✓ Email sent to #{recipient_email}"
  rescue StandardError => e
    Rails.logger.error "✗ Failed to send email to #{recipient_email}: #{e.message}"
    raise
  end

  # Send emails to multiple recipients in a batch
  def self.send_batch!(campaign:, recipient_emails:)
    success_count = 0
    failure_count = 0

    recipient_emails.each do |email|
      sender = new(campaign: campaign, recipient_email: email)
      sender.send_email!
      success_count += 1
    rescue StandardError => e
      Rails.logger.warn "Failed to send to #{email}: #{e.message}"
      failure_count += 1
    end

    {
      success: success_count,
      failed: failure_count,
      total: recipient_emails.size
    }
  end

  private

  def personalize_content
    # Simulated personalization time
    sleep(0.02)
  end

  def deliver_email
    # Simulated delivery time
    sleep(0.1)

    # Simulate 0.5% delivery failure rate
    raise "Delivery failed: invalid email" if rand < 0.005
  end

  def setup_tracking
    # Simulated tracking setup time
    sleep(0.01)
  end
end
