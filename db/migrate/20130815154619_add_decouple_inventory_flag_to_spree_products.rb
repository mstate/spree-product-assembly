class AddDecoupleInventoryFlagToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :decouple_inventory_from_parts, :boolean, default: false
  end
end
