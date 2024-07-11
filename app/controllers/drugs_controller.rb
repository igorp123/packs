class DrugsController < ApplicationController
  before_action :set_drug, only: %i[show]

  def index
    @firms = Firm.all
    @drugs = Drug.all
  end

  def show
    @firms = Firm.all
    @sgtins = @drug.sgtin.all
    @batches = @drug.batch.all
  end
end


private

def set_drug
  @drug = Drug.find(params[:id])
end
