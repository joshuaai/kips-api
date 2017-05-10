class RenameUrlToLinkUrl < ActiveRecord::Migration[5.0]
  def change
    rename_column :links, :url, :link_url
  end
end
