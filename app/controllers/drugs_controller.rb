class DrugsController < ApplicationController
  before_action :set_drug, only: %i[show]

  def index
    @drugs = Drug.all
  end

  def show
    @sgtins = @drug.sgtin.all
  end
end


private

def drugs_params
  params.require(:drug).permit(:name)
end

def set_drug
  @drug = Drug.find_by(params[:id])
end
