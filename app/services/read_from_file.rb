class ReadFromFile < ApplicationService
  def call
    firm = Firm.third

    file = 'tf.xlsx'

    drugs_from(file)

    Batch.import batches_from(file), ignore: true

    BatchFirm.import quantity_from(file, firm), ignore: true
  end

  private

  def drugs_from(file)
    sheet = RubyXL::Parser.parse(file)[0]

    producer = Producer.first

    sheet.map do |row|
      cells = row.cells

      Drug.find_or_create_by(gtin: cells[0].value) do |drug| #1
        drug.name = cells[1].value.capitalize #5
        #drug.mnn = cells[4].value.capitalize #4
        drug.producer = producer
      end
    end
  end

  def batches_from(file)
    sheet = RubyXL::Parser.parse(file)[0]

    sheet.map do |row|
      cells = row.cells

      drug = Drug.find_by(gtin: cells[1].value)

      Batch.new(number: cells[2].value,
                expiration_date: cells[3].value,
                drug: drug
                )
    end
  end

  def quantity_from(file, firm)
    sheet = RubyXL::Parser.parse(file)[0]

    sheet.map do |row|
      cells = row.cells

      drug = Drug.find_by(gtin: cells[0].value)

      batch = drug.batch.find_by(number: cells[2].value)

      firm.batch_firms.new(batch: batch, quantity: cells[6].value)
    end
  end
end
