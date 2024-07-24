class ReadFromMdlp < ApplicationService
  ENDPOINT = 'https://api.mdlp.crpt.ru/api'
  CLIENT_SECRET = Rails.application.credentials.client_secret
  CLIENT_ID = Rails.application.credentials.client_id
  USER_ID = Rails.application.credentials.user_id
  STEP = 100

  OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def initialize
    @user_id = connection_params['user_id']
    @client_id = connection_params['client_id']
    @client_secret = connection_params['client_secret']
    @auth_type = connection_params['auth_type']
    @token = Token.first_or_create(token: '12345678', expiration_date: '01.01.2024',
      last_operation_time: '01.01.2024')
  end

  def call
    #Firm.all.each do |firm|
      firm = Firm.first

      authorise(connection_params)

      total_records = read_sgtins_from_mdlp(start_position(firm))['total'].to_i

      while start_position(firm) <= total_records
          sleep 5

          response = read_sgtins_from_mdlp(start_position(firm))

          response['entries'].each do |entry|
            puts "#{entry['sgtin']} #{entry['status']} #{entry['prod_name']} #{entry['last_tracing_op_date']}}"

            producer = set_producer(entry['packing_inn'], entry['packing_name'])

            drug = set_drug(entry['gtin'], entry['sell_name'], entry['prod_name'], entry['prod_form_name'],
            entry['prod_d_name'], producer)

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
      end
    #end
  end

  private

  def set_producer(inn, name)
    Producer.find_or_create_by(inn: inn) do |producer|
      producer.name = name
    end
  end

  def set_drug(gtin, name, mnn, form_name, form_doze, producer)

    Drug.find_or_create_by(gtin: gtin) do |drug|
      drug.name = name.capitalize()
      drug.mnn = mnn.capitalize()
      drug.form_name = form_name.downcase()
      drug.form_doze = form_doze
      drug.producer = producer
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
    cert = OpenSSL::X509::Certificate.new(File.read('raj.crt'))

    private_key = OpenSSL::PKey.read(File.read('raj.pem'))

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

  def start_position(firm)
    Sgtin.where(firm: firm).count + 1
  end

  def read_sgtins_from_mdlp(start)
    url = "#{ENDPOINT}/v1/reestr/sgtin/filter"
      headers =
      {
        'Content-Type' => 'application/json',  'Authorization' => "token #{@token.token}"
      }

      body =
        {
          'start_from' => start,
          'count' => STEP,
          'filter' => { "status" => ['in_circulation', 'in_realization'] }
        }
      request_to_api(:post, url, headers, body)
  end

  def translate_status(status)
    return 'В обороте' if status == 'in_circulation'

    'Отгружен'
  end
end
