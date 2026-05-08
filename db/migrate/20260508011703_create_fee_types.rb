class CreateFeeTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :fee_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
