Spree::LineItem.class_eval do
  
  validate :validate_quantity_and_stock

  private

  def validate_quantity_and_stock
    unless quantity && quantity >= 0
      errors.add(:quantity, I18n.t("validation.must_be_non_negative"))
    end
    # avoid reload of order.inventory_units by using direct lookup
    unless !Spree::Config[:track_inventory_levels]   ||
           Spree::Config[:allow_backorders]          ||
           order   && order.inventory_units.present? ||
           variant && quantity <= variant.on_hand
      errors.add(:quantity, I18n.t("validation.is_too_large") + " (#{self.variant.name})")
    end

    return unless variant
  end

end
