class CreateEmailCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :email_campaigns do |t|
      t.string :name, null: false
      t.string :subject, null: false
      t.string :status, null: false, default: "pending"
      t.integer :sent_count, default: 0, null: false
      t.integer :total_recipients, null: false

      t.timestamps
    end

    add_index :email_campaigns, :status
    add_index :email_campaigns, :created_at
  end
end
