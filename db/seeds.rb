100.times do
  #drug
  name = Faker::Commerce.product_name
  gtin = "0#{Faker::Barcode.ean(13)}"

  Drug.create(name: name, gtin: gtin)
end

300.times do
  #batch

  number = Faker::Alphanumeric.alphanumeric(number: 10)
  expiration_date = Faker::Date.between(from: '2024-01-01', to: '2027-12-31')
  drug = Drug.all.sample

  Batch.create(number: number, expiration_date: expiration_date, drug: drug)
end

3000.times do
  #sgtin

  status = [:in_realization, :in_circulation].sample
  status_date = Faker::Date.between(from: 3.years.ago, to: Date.today)
  last_operation_date = status_date
  batch = Batch.all.sample
  drug = batch.drug
  number = "#{drug.gtin}#{Faker::Barcode.ean(13)}"
  firm = Firm.all.sample

  Sgtin.create(
                drug: drug, batch: batch, status: status, status_date: status_date,
                number: number, firm: firm, last_operation_date: last_operation_date
              )
end
