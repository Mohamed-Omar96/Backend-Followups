require 'rails_helper'

RSpec.describe EmailCampaign, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:total_recipients) }
  end

  describe '#progress_percentage' do
    let(:campaign) { create(:email_campaign, sent_count: 50, total_recipients: 100) }

    it 'calculates progress percentage' do
      expect(campaign.progress_percentage).to eq(50.0)
    end

    it 'returns 0 when total is zero' do
      campaign.total_recipients = 0
      expect(campaign.progress_percentage).to eq(0)
    end
  end

  describe '#increment_sent_count!' do
    let(:campaign) { create(:email_campaign, sent_count: 10) }

    it 'increments sent count' do
      campaign.increment_sent_count!(5)
      expect(campaign.sent_count).to eq(15)
    end
  end
end
