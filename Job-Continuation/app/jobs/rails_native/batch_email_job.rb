# Rails 8 Native job continuation example - Batch processing
# Demonstrates checkpoint frequency trade-offs with batch-level checkpoints
module RailsNative
  class BatchEmailJob < ApplicationJob
    include ActiveJob::Continuable
    include Interruptible

    queue_as :default

    BATCH_SIZE = 50 # Process 50 emails per batch

    def perform(campaign_id)
      @campaign = EmailCampaign.find(campaign_id)

      Rails.logger.info "=" * 80
      Rails.logger.info "Starting BatchEmailJob (Rails 8 Native - Batched)"
      Rails.logger.info "Campaign: #{@campaign.name}"
      Rails.logger.info "Total Recipients: #{@campaign.total_recipients}"
      Rails.logger.info "Batch Size: #{BATCH_SIZE}"
      Rails.logger.info "=" * 80

      # Load recipients (runs every time, including on resume)
      @recipient_emails = generate_recipient_emails(@campaign.total_recipients)
      Rails.logger.info "Loaded #{@recipient_emails.count} recipient emails"
      @campaign.mark_as_in_progress!

      # Step: Process recipients in batches
      step :process_batches do |step|
        batches = @recipient_emails.each_slice(BATCH_SIZE).to_a
        total_batches = batches.count
        cursor = step.cursor || 0  # Cursor defaults to nil on first run

        Rails.logger.info "Processing #{total_batches} batches (#{BATCH_SIZE} emails per batch)"

        # Skip already-processed batches
        batches.drop(cursor).each_with_index do |batch, batch_idx|
          batch_position = cursor + batch_idx
          batch_number = batch_position + 1

          check_interruption_flag

          Rails.logger.info "Processing batch #{batch_number}/#{total_batches} (#{batch.size} emails)"

          # Send all emails in this batch
          results = EmailSender.send_batch!(
            campaign: @campaign,
            recipient_emails: batch
          )

          # Update campaign progress
          @campaign.increment_sent_count!(results[:success])

          # Checkpoint after each batch (not each email)
          # This is the key difference from per-item checkpointing
          step.advance! from: batch_position + 1

          Rails.logger.info "  Batch #{batch_number} complete: #{results[:success]} sent, #{results[:failed]} failed"
          Rails.logger.info "  Campaign progress: #{@campaign.progress_percentage}%"
        end
      end

      @campaign.mark_as_completed!

      Rails.logger.info "=" * 80
      Rails.logger.info "Email campaign completed!"
      Rails.logger.info "Total sent: #{@campaign.sent_count}/#{@campaign.total_recipients}"
      Rails.logger.info "Success rate: #{(@campaign.sent_count.to_f / @campaign.total_recipients * 100).round(2)}%"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end

    private

    def generate_recipient_emails(count)
      # In a real app, this would query database for actual recipients
      # For demo purposes, generate fake emails
      (1..count).map { |i| "user#{i}@example.com" }
    end
  end
end
