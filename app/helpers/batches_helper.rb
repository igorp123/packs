module BatchesHelper
  def sgtins_at_firm(sgtins, firm)
    sgtins.select{ |sgtin| sgtin.firm == firm }
  end
end
