class ReadGtins < ApplicationService
  def call
    File.readlines('gtins.txt', chomp: true).each do |gtin|
      Gtin.find_or_create_by(number: gtin)
    end
  end
end
