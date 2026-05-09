class AddCreatedByToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :created_by_id, :integer
  end
end
