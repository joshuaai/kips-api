class AddLinCountToCateg < ActiveRecord::Migration[5.0]
  def change
    add_column :categs, :lins_count, :integer, default: 0
    Categ.all.each do |c|
      Categ.update_counters c.id, lins_count: c.lins.length
    end
  end
end
