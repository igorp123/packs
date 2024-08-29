class ReadFromMdlp < ApplicationService
  ENDPOINT = 'https://api.mdlp.crpt.ru/api'
  CLIENT_SECRET = Rails.application.credentials.client_secret
  CLIENT_ID = Rails.application.credentials.client_id
  USER_ID = Rails.application.credentials.user_id
  STEP = 100

  OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def initialize(gtin = nil, batch = nil, firm = nil)
    @user_id = connection_params['user_id']
    @client_id = connection_params['client_id']
    @client_secret = connection_params['client_secret']
    @auth_type = connection_params['auth_type']
    @token = Token.first_or_create(token: '12345678', expiration_date: '01.01.2024',
      last_operation_time: '01.01.2024')
    @gtin = gtin
    @batch = batch
    @firm = firm
  end

  def call
    authorise(connection_params)

    if @gtin
      read_sgtin_from_reestr(@gtin, @batch, @firm)
    else
      read_drug_info
    end
  end

  def read_drug_info
    drugs = Drug.all

    drugs.each do |drug|
      sleep 1

      entry = read_gtin_info_from_mdlp(drug.gtin)

      producer = set_producer_for_gtin_info(entry['glf_name'])

      drug.form_name = entry['prod_form_norm_name'].downcase()
      drug.form_doze = entry['prod_d_norm_name'] == 'НЕ УКАЗАНО' ? entry['prod_d_name'] : entry['prod_d_norm_name']
      drug.producer = producer
      drug.is_narcotic = entry['is_narcotic']
      drug.is_pku = entry['is_pku']

      drug.save
    end
  end

  def read_sgtin_from_reestr(gtin, batch, firm)
        start = 0

        sleep 5

        total_records = read_sgtins_from_mdlp(start, gtin, batch.number, firm)['total'].to_i

        #gtin.update_attribute(:total_rj, total_records)

        #next if total_records == 0

        while start <= total_records do
            puts '--------------------------'
            puts "#{start} / #{total_records}"
            puts '--------------------------'
            sleep 5

            response = read_sgtins_from_mdlp(start, gtin, batch.number, firm)

            drug = batch.drug

            response['entries'].each do |entry|
              sgtin =
                Sgtin.create(
                              number: entry['sgtin'],
                              drug: drug,
                              batch: batch,
                              status: translate_status(entry['status']),
                              status_date: entry['status_date'],
                              last_operation_date: entry['last_tracing_op_date'],
                              firm: firm,
                            )
            end
            start += STEP
        end
  end

  def read_sgtin_from_reestr_old()
    #Firm.all.each do |firm|
      firm = Firm.first

      #gtins = Gtin.all.order(:id)

      gtins = Gtin.where.not(total_rj: 0).or(Gtin.where(total_rj: nil))

      gtins.each do |gtin|
        drug = Drug.find_by(gtin: gtin.number)

        if drug
          next if gtin.total_rj && gtin.total_rj == Sgtin.where(drug: drug, firm: firm).count

          start = start_position(drug, firm)
        else
          start = 0
        end

        sleep 5

        total_records = read_sgtins_from_mdlp(start, gtin.number)['total'].to_i

        gtin.update_attribute(:total_rj, total_records)

        next if total_records == 0

        while start <= total_records do
            puts '--------------------------'
            puts "#{start} / #{total_records}"
            puts '--------------------------'
            sleep 5

            response = read_sgtins_from_mdlp(start, gtin.number)

            response['entries'].each do |entry|

              producer = set_producer(entry['packing_inn'], entry['packing_name'])

              drug = set_drug(entry['gtin'], entry['sell_name'], entry['prod_name'], entry['prod_form_name'],
              entry['prod_d_name'], producer, entry['is_narcotic?'], entry['is_pku?'])

              batch = set_batch(entry['batch'], drug, entry['expiration_date'])

              sgtin =
                Sgtin.create(
                              number: entry['sgtin'],
                              drug: drug,
                              batch: batch,
                              status: translate_status(entry['status']),
                              status_date: entry['status_date'],
                              last_operation_date: entry['last_tracing_op_date'],
                              firm: firm,
                            )
            end
            start += STEP
        end
      end
  end

  private

  def set_producer(inn, name)
    Producer.find_or_create_by(inn: inn) do |producer|
      producer.name = name
    end
  end

  def set_producer_for_gtin_info(name)
    Producer.find_or_create_by(name: name)
  end

  def set_drug(gtin, name, mnn, form_name, form_doze, producer, is_narcotic, is_pku)
    Drug.find_or_create_by(gtin: gtin) do |drug|
      drug.name = name.capitalize()
      drug.mnn = mnn.capitalize()
      drug.form_name = form_name.downcase()
      drug.form_doze = form_doze
      drug.producer = producer
      drug.is_narcotic = is_narcotic
      drug.is_pku = is_pku
    end
  end

  def set_batch(batch_number, drug, expiration_date)
    Batch.find_or_create_by(drug: drug, number: batch_number) do |batch|
      batch.expiration_date = expiration_date
    end
  end

  def connection_params
    {
     'client_secret' => CLIENT_SECRET,
     'client_id' => CLIENT_ID,
     'user_id' => USER_ID,
     'auth_type' => 'SIGNED_CODE'
    }
  end

  def authorise(connection_params)
    return if authorised?

    code = get_code

    get_token(code, sign_code(code))
  end

  def authorised?
    @token.expiration_date > Time.now && Time.now - @token.last_operation_time < 1800
  end

  def get_code()
    url = "#{ENDPOINT}/v1/auth"

    headers = { 'Content-Type' => 'application/json;charset=UTF-8' }

    body =
      {
       'client_secret' => @client_secret,
       'client_id' => @client_id,
       'user_id' => @user_id,
       'auth_type' => @auth_type
      }

    request_to_api(:post, url, headers, body)['code']
  end

  def sign_code(code)
    cert = OpenSSL::X509::Certificate.new(File.read('igor.crt'))

    private_key = OpenSSL::PKey.read(File.read('igor.pem'))

    sign_code = OpenSSL::PKCS7::sign(cert, private_key, code, [], OpenSSL::PKCS7::DETACHED)

    sign_code.to_s.gsub(/-----.+-----/,"").gsub("\n","")

  end

  def get_token(code, signed_code)
    url = "#{ENDPOINT}/v1/token"

    headers = { 'Content-Type' => 'application/json;charset=UTF-8' }

    body = { code: code, signature: signed_code }

    request_token = request_to_api(:post, url, headers, body)

    @token.token = request_token['token']
    @token.expiration_date = Time.now + request_token['life_time'] * 60
    @token.save

    #binding.break
  end

  def request_to_api(type, url, headers, body = {})
    begin
      if type == :post
        result = HTTParty.post(url, body: JSON.generate(body), headers: headers)
      else
        result = HTTParty.get(url, headers: headers)
      end
    rescue
      abort 'Не удалось подключиться к API'
    end

    abort "#{result['error_description'] || result['error']}" unless result.code == 200

    @token.update_attribute(:last_operation_time, Time.now)

    result
  end

  def start_position(drug, firm)
    Sgtin.where(drug: drug, firm: firm).count + 1
  end

  def read_sgtins_from_mdlp(start, gtin, batch, firm)
    puts '--------------------------'
    puts batch
    puts '---------------------------'
    url = "#{ENDPOINT}/v1/reestr/sgtin/filter"
      headers =
      {
        'Content-Type' => 'application/json',  'Authorization' => "token #{@token.token}"
      }

      body =
        {
          'start_from' => start,
          'count' => STEP,
          'filter' => { "status" => ['in_circulation', 'in_realization'],
                         "gtin" => gtin,
                         "batch" => batch
                      }
        }
      request_to_api(:post, url, headers, body)
  end

  def read_gtin_info_from_mdlp(gtin)
    url = "#{ENDPOINT}/v1/reestr/med_products/public/#{gtin}"

    headers =
     {
        'Content-Type' => 'application/json',  'Authorization' => "token #{@token.token}"
     }

      body = { }
      request_to_api(:get, url, headers, body)
  end

  def translate_status(status)
    return 'В обороте' if status == 'in_circulation'

    'Отгружен'
  end
end
