class RenameEmaillToColor < ActiveRecord::Migration[5.0]
  def change
    rename_column :categs, :email, :color
  end
end
