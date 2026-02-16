require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'associations' do
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
  end

  describe 'scopes' do
    let!(:recent_customer) { create(:customer, created_at: 1.month.ago) }
    let!(:old_customer) { create(:customer, created_at: 2.years.ago) }

    it 'returns active customers' do
      expect(Customer.active).to include(recent_customer)
      expect(Customer.active).not_to include(old_customer)
    end

    it 'orders by created_at desc' do
      expect(Customer.recent.first).to eq(recent_customer)
    end
  end
end
