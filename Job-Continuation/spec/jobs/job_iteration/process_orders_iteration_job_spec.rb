require 'rails_helper'

RSpec.describe JobIteration::ProcessOrdersIterationJob, type: :job do
  describe '#perform' do
    let!(:pending_orders) { create_list(:order, 5, status: 'pending') }

    it 'enqueues the job' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class)
    end

    context 'enumerator' do
      it 'builds enumerator with nil cursor' do
        job = described_class.new
        enumerator = job.build_enumerator(cursor: nil)

        expect(enumerator).to be_a(Enumerator)
      end
    end
  end

  describe 'job configuration' do
    it 'includes Iteration module' do
      expect(described_class.ancestors).to include(::JobIteration::Iteration)
    end

    it 'includes Interruptible concern' do
      expect(described_class.ancestors).to include(Interruptible)
    end

    it 'uses default queue' do
      expect(described_class.new.queue_name).to eq('default')
    end
  end
end
