class SgtinImportJob < ApplicationJob
  queue_as :default

  def perform(gtin, batch, firm)
    ReadFromMdlp.call(gtin, batch, firm)
  end
end
