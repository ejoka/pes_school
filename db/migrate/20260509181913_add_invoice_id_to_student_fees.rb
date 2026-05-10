class AddInvoiceIdToStudentFees < ActiveRecord::Migration[8.0]
  def change
    add_column :student_fees, :invoice_id, :integer
  end
end
