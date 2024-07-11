class DrugsController < ApplicationController
  before_action :set_drug, only: %i[show]

  def index
    @firms = Firm.all
    @drugs = Drug.all.order(:name)
  end

  def show
    @firms = Firm.all
    @sgtins = @drug.sgtin.all
    @batches = @drug.batch.all.order(:number)
  end
end


private

def set_drug
  @drug = Drug.find(params[:id])
end
