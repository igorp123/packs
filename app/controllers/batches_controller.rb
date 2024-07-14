class BatchesController < ApplicationController
  before_action :set_drug1, only: %i[show]
  before_action :set_batch, only: %i[show]
  before_action :set_firm, only: %i[show]

  def show
    @sgtins = Sgtin.where(batch: @batch)
    @firms = Firm.all

    respond_to do |format|
      format.html do
      end

      format.zip {respond_with_zip_sgtins}
    end
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

def respond_with_zip_sgtins
  compressed_filestream = Zip::OutputStream.write_buffer do |zos|
    zos.put_next_entry "#{@batch.number}.xlsx"

    zos.print render_to_string(
      layout: false, handlers: [:axlsx], formats: [:xlsx],
      template: 'batches/batch', locals: {firms: @firms, sgtins: @sgtins}
    )
  end

  compressed_filestream.rewind

  send_data compressed_filestream.read, filename: "#{@drug.name}.zip"
end
