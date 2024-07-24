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
    @token = Token.first
  end

  def call
    #Firm.all.each do |firm|
      firm = Firm.first

      authorise(connection_params)

      response = read_sgtins_from_mdlp(start_position(firm))

      response['entries'].each do |entry|
        puts "#{entry['sgtin']} #{entry['status']} #{entry['prod_name']} #{entry['last_tracing_op_date']}}"

        drug = set_drug(entry['gtin'], entry['sell_name'], entry['prod_name'], entry['prod_form_name'],
        entry['prod_d_name'])

        batch = set_batch(entry['batch'], drug, entry['expiration_date'])

        sgtin = Sgtin.create(number: entry['sgtin'], status: entry['status'], firm: firm,
         batch: batch, drug: drug, last_operation_date: entry['last_tracing_op_date'],
         status_date: entry['status_date'])

        sgtin.save
      end

    #end
  end

  private

  def set_drug(gtin, name, mnn, form_name, form_doze)
    #Drug.find_or_create_by(gtin: gtin, name: name)

    Drug.find_or_create_by(gtin: gtin) do |drug|
      drug.name = name
      drug.mnn = mnn
      drug.form_name = form_name
      drug.form_doze = form_doze
    end




  end

  def set_batch(batch_number, drug, expiration_date)
    Batch.find_or_create_by(drug: drug, number: batch_number, expiration_date: expiration_date)
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
          'filter' => { "sys_id" => "00000000107321",
                        "status" => ['in_circulation', 'in_realization'],
                        #"batch" => "030321"
                        # "gtin" => "00000046100146",
                        #'' 'in_realization'
                        #"last_tracing_op_date_to" => "2024-05-22"
                        #"source" => 'primary'
                      }
        }
      request_to_api(:post, url, headers, body)
  end
end
