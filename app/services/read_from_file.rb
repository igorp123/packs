class ReadFromFile < ApplicationService
  def call
    firm = Firm.first

    file = 'rj.xlsx'

    #drugs_from(file)

    #Batch.import batches_from(file), ignore: true

    BatchFirm.import quantity_from(file, firm), ignore: true
  end

  private

  def drugs_from(file)
    sheet = RubyXL::Parser.parse(file)[0]

    producer = Producer.first

    sheet.map do |row|
      cells = row.cells

      Drug.create gtin: cells[0].value,
               name: cells[4].value.capitalize(),
               mnn: cells[3].value.capitalize(),
               producer: producer
    end
  end

  def batches_from(file)
    sheet = RubyXL::Parser.parse(file)[0]

    sheet.map do |row|
      cells = row.cells

      drug = Drug.find_by(gtin: cells[0].value)

      Batch.new number: cells[1].value,
                expiration_date: cells[2].value,
                drug: drug
    end
  end

  def quantity_from(file, firm)
    sheet = RubyXL::Parser.parse(file)[0]

    sheet.map do |row|
      cells = row.cells

      drug = Drug.find_by(gtin: cells[0].value)

      batch = drug.batch.find_by(number: cells[1].value)

      firm.batch_firms.new(batch: batch, quantity: cells[5].value)
    end
  end
end
