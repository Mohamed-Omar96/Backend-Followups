require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe 'scopes' do
    let!(:pending_order) { create(:order, status: 'pending') }
    let!(:processed_order) { create(:order, status: 'processed', processed_at: Time.current) }
    let!(:failed_order) { create(:order, status: 'failed') }

    it 'returns pending orders' do
      expect(Order.pending).to include(pending_order)
      expect(Order.pending).not_to include(processed_order)
    end

    it 'returns processed orders' do
      expect(Order.processed).to include(processed_order)
      expect(Order.processed).not_to include(pending_order)
    end

    it 'returns failed orders' do
      expect(Order.failed).to include(failed_order)
      expect(Order.failed).not_to include(pending_order)
    end
  end

  describe '#mark_as_processed!' do
    let(:order) { create(:order, status: 'pending') }

    it 'updates status to processed' do
      order.mark_as_processed!
      expect(order.status).to eq('processed')
    end

    it 'sets processed_at timestamp' do
      order.mark_as_processed!
      expect(order.processed_at).to be_present
    end
  end
end
