class AddPermissionsToUserResource < ActiveRecord::Migration[8.0]
  def change
    add_column :user_resources, :permissions, :jsonb
  end
end
