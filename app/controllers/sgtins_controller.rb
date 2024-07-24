class SgtinsController < ApplicationController
  def destroy
   @sgtin = Sgtin.find(params[:id])
   @batch = @sgtin.batch

   @sgtin.destroy

   redirect_to drug_batch_path(@batch.drug, @batch)
  end
end
