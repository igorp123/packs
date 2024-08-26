module DrugsHelper
  def quantity_at_firm(drug, firm)
    drug.sgtin.where(firm: firm.id).count
  end

  def quantity_at_firm_by_bathes(drug, firm, batch)
    drug.sgtin.where(firm: firm.id, batch: batch.id).count
  end

  def quantity_at_firm_by_batches_mdlp(firm, batch)
    batches = batch.batch_firms.find_by(batch: batch, firm: firm)
    batches ? batches.quantity : 0
    end
end
