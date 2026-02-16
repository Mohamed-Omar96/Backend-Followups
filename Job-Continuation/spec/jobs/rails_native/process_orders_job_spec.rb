require 'rails_helper'

RSpec.describe RailsNative::ProcessOrdersJob, type: :job do
  describe '#perform' do
    let!(:pending_orders) { create_list(:order, 5, status: 'pending') }

    it 'enqueues the job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class)
    end
  end

  describe 'job configuration' do
    it 'includes Continuable module' do
      expect(described_class.ancestors).to include(ActiveJob::Continuable)
    end

    it 'includes Interruptible concern' do
      expect(described_class.ancestors).to include(Interruptible)
    end

    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end
end
