class BatchesController < ApplicationController
  before_action :set_drug1, only: %i[show]
  before_action :set_batch, only: %i[show]
  before_action :set_firm, only: %i[show]

  def show
   # render plain: params
    @sgtins = Sgtin.where(batch: @batch)
    @firms = Firm.all
  end
end

private

def set_drug1
  @drug = Drug.find(params[:drug_id])
end

def set_batch
  @batch = @drug.batch.find(params[:id])
end

def set_firm
  return @firm = Firm.find(params[:firm_id]) if params[:firm_id].present?
  @firm = Firm.first
end
