class SetDefaultValuesForStudentFeeItems < ActiveRecord::Migration[7.0]
  def change
    change_column_default :student_fee_items, :amount, 0
    change_column_default :student_fee_items, :paid, 0
    change_column_default :student_fee_items, :status, 'unpaid'
    
    # Update any existing nil values
    StudentFeeItem.where(amount: nil).update_all(amount: 0)
    StudentFeeItem.where(paid: nil).update_all(paid: 0)
    StudentFeeItem.where(status: nil).update_all(status: 'unpaid')
  end
end