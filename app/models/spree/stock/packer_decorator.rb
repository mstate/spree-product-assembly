module Spree
  module Stock
    Packer.class_eval do
      # Overriden from Spree core to build a custom package instead of the
      # default_package built in Spree
      def packages
        if splitters.empty?
          [product_assembly_package]
        else
          build_splitter.split [product_assembly_package]
        end
      end

      # Returns a package with all products from current stock location
      #
      # Follows the same logic as `Packer#default_package` except that it
      # loops through associated product parts (which is really just a
      # product / variant) to include them on the package if available.
      #
      # The product bundle itself is not included on the shipment because it
      # doesn't actually should have stock items, it's not a real product.
      # We track its parts stock items instead.
      def product_assembly_package
        package = Package.new(stock_location)
        inventory_units.group_by(&:variant).each do |variant, variant_inventory_units|
          product = variant.product
          if product.assembly?
            product.parts.each do |part|
              if part.should_track_inventory?
                next unless stock_location.stock_item(part)                
                units = variant_inventory_units.clone # this could be wrong to count the quantity of assembled product in order    

                on_hand, backordered = stock_location.fill_status(part, units.count * product.count_of(part))
                package.add_multiple units.slice!(0, on_hand), :on_hand if on_hand > 0
                package.add_multiple units.slice!(0, backordered), :backordered if backordered > 0
              else
                package.add units.slice!(0, on_hand), :on_hand
              end
            end          
          elsif variant.should_track_inventory?
            next unless stock_location.stock_item(variant)
            units = variant_inventory_units.clone          

            on_hand, backordered = stock_location.fill_status(variant, units.count)
            package.add_multiple units.slice!(0, on_hand), :on_hand if on_hand > 0
            package.add_multiple units.slice!(0, backordered), :backordered if backordered > 0
          else
            package.add_multiple units
          end
        end
        package        
      end
    end
  end
end
