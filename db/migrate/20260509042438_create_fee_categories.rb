class CreateFeeCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :fee_categories do |t|
      t.string :name
      t.string :description
      t.boolean :is_recurring, default: false

      t.timestamps
    end
  end
end
