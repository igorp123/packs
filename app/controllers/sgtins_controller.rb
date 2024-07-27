class SgtinsController < ApplicationController
  def destroy
  # render plain: params
  @sgtin = Sgtin.find(params[:id])
  @batch = @sgtin.batch

  @sgtins = Sgtin.where(batch: @batch, firm: @sgtin.firm).map.with_index{ |e, i| i if e.number ==@sgtin.number }.compact

  #  @sgtin.destroy

   render plain: @sgtins
  #redirect_to drug_batch_path(@batch.drug, @batch)
  end
end
