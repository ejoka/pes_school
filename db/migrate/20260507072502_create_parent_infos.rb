class CreateParentInfos < ActiveRecord::Migration[8.0]
  def change
    create_table :parent_infos do |t|
      t.references :student, null: false, foreign_key: true
      t.string :father_name
      t.string :father_occupation
      t.string :father_phone
      t.string :father_email
      t.string :mother_name
      t.string :mother_occupation
      t.string :mother_phone
      t.string :mother_email
      t.string :guardian_name
      t.string :guardian_occupation
      t.string :guardian_phone
      t.string :guardian_email

      t.timestamps
    end
  end
end
