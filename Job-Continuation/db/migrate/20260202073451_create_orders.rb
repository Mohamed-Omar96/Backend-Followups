class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :processed_at

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :processed_at
    add_index :orders, :created_at
    add_index :orders, [:customer_id, :status]
  end
end
