class ReadFromFile < ApplicationService
  def call
    file = 'rj.xlsx'

    drugs_from(file)

    Batch.import batches_from(file), ignore: true
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
end
