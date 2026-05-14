class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :contact_person
      t.string :phone
      t.string :email
      t.text :address
      t.text :notes

      t.timestamps
    end
  end
end
