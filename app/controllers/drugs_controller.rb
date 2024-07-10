class DrugsController < ApplicationController
  before_action :set_drug, only: %i[show]
  before_action :set_firm, only: %i[index]

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

# def drugs_params
#   params.require(:drug).permit(:name)
# end

def set_drug
  @drug = Drug.find(params[:id])
end


# def set_firm
#   return @firm = Firm.find(params[:firm_id]) if params[:firm_id].present?
#   @firm = Firm.first
# end
