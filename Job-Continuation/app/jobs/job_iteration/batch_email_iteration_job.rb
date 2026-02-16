# job-iteration example - Batch enumerator pattern
# Demonstrates batch processing with checkpoint per batch
module JobIteration
  class BatchEmailIterationJob < ApplicationJob
    include ::JobIteration::Iteration
    include Interruptible

    queue_as :default

    BATCH_SIZE = 50 # Process 50 emails per batch

    # Build batch enumerator
    def build_enumerator(campaign_id, cursor:)
      @campaign = EmailCampaign.find(campaign_id)

      Rails.logger.info "=" * 80
      Rails.logger.info "Building batch enumerator for BatchEmailIterationJob"
      Rails.logger.info "Campaign: #{@campaign.name}"
      Rails.logger.info "Total Recipients: #{@campaign.total_recipients}"
      Rails.logger.info "Batch Size: #{BATCH_SIZE}"
      Rails.logger.info "Resuming from batch: #{cursor || 0}"
      Rails.logger.info "=" * 80

      @campaign.mark_as_in_progress! if cursor.nil?

      # Generate recipient emails
      recipient_emails = generate_recipient_emails(@campaign.total_recipients)

      # Create batches and wrap in array enumerator
      batches = recipient_emails.each_slice(BATCH_SIZE).to_a

      # Use array enumerator for batches (cursor is batch index)
      enumerator_builder.array(batches, cursor: cursor)
    end

    # Called once per batch
    def each_iteration(batch, campaign_id)
      @campaign ||= EmailCampaign.find(campaign_id)

      check_interruption_flag

      # Calculate batch number for logging
      cursor = cursor_position || 0
      total_batches = (@campaign.total_recipients.to_f / BATCH_SIZE).ceil
      batch_number = cursor + 1

      Rails.logger.info "Processing batch #{batch_number}/#{total_batches} (#{batch.size} emails)"

      # Send all emails in this batch
      results = EmailSender.send_batch!(
        campaign: @campaign,
        recipient_emails: batch
      )

      # Update campaign progress
      @campaign.increment_sent_count!(results[:success])

      # Log results
      Rails.logger.info "  Batch #{batch_number} complete: #{results[:success]} sent, #{results[:failed]} failed"
      Rails.logger.info "  Campaign progress: #{@campaign.progress_percentage}%"

      # Checkpoint saved automatically after each batch
    end

    # Called once after all batches complete
    def on_complete
      @campaign.mark_as_completed!

      Rails.logger.info "=" * 80
      Rails.logger.info "Email campaign completed!"
      Rails.logger.info "Total sent: #{@campaign.sent_count}/#{@campaign.total_recipients}"
      Rails.logger.info "Success rate: #{(@campaign.sent_count.to_f / @campaign.total_recipients * 100).round(2)}%"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end

    # Called on interruption
    def on_shutdown
      cursor = cursor_position
      total_batches = (@campaign.total_recipients.to_f / BATCH_SIZE).ceil
      Rails.logger.info "Job interrupted at batch #{cursor}/#{total_batches}, checkpoint saved"
    end

    private

    def generate_recipient_emails(count)
      # In a real app, this would query database for actual recipients
      # For demo purposes, generate fake emails
      (1..count).map { |i| "user#{i}@example.com" }
    end
  end
end
