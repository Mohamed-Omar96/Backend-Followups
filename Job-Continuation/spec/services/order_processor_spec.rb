require 'rails_helper'

RSpec.describe OrderProcessor do
  let(:order) { create(:order, status: 'pending') }
  let(:processor) { described_class.new(order) }

  describe '#process!' do
    it 'marks order as processed on success' do
      processor.process!
      expect(order.reload.status).to eq('processed')
      expect(order.processed_at).to be_present
    end

    it 'marks order as failed on error' do
      allow(processor).to receive(:process_payment).and_raise(StandardError, "Payment failed")

      expect { processor.process! }.to raise_error(StandardError)
      expect(order.reload.status).to eq('failed')
    end
  end
end
