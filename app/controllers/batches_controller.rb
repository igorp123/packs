class BatchesController < ApplicationController
  before_action :set_drug1, only: %i[show]
  before_action :set_batch, only: %i[show]

  def show
   # render plain: params
    @sgtins = Sgtin.where(batch: @batch)
  end
end


private

def set_drug1
  @drug = Drug.find(params[:drug_id])
end

def set_batch
  @batch = @drug.batch.find(params[:id])
end
