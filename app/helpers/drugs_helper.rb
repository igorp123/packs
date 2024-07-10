module DrugsHelper
  def quantity_at_firm(drug, firm)
    drug.sgtin.where(firm: firm.id).count
  end

  def quantity_at_firm_by_bathes(drug, firm, batch)
    drug.sgtin.where(firm: firm.id, batch: batch.id).count
  end
end
