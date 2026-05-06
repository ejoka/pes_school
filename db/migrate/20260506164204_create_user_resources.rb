class CreateUserResources < ActiveRecord::Migration[8.0]
  def change
    create_table :user_resources do |t|
      t.references :user, null: false, foreign_key: true
      t.string :resource_type
      t.integer :resource_id

      t.timestamps
    end
  end
end
