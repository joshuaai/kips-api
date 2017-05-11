class CreateLins < ActiveRecord::Migration[5.0]
  def change
    create_table :lins do |t|
      t.string :title
      t.string :link_url
      t.references :categ, foreign_key: true

      t.timestamps
    end
  end
end
