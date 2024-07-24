 require 'httparty'
 require 'json'

class ReadFromMdlp < ApplicationService
  ENDPOINT = 'https://api.mdlp.crpt.ru/api'
  CLIENT_SECRET = 'b36d13d9-867e-4c3f-98af-9e3f757c79cc'
  CLIENT_ID = '2967d2f4-45b5-404b-b1b1-517e27eab732'
  USER_ID = 'a0499e63-c023-4456-a640-5360075fd379'

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
      authorise(connection_params)
      response = read_sgtins_from_mdlp(1, 100)

      response['entries'].each do |entry|
        puts "#{entry['sgtin']} #{entry['status']} #{entry['prod_name']} #{entry['last_tracing_op_date']} #{entry['total_cost']}"
      end

    #end
  end

  private

  def read_sgtins_from_mdlp(start, step)
    url = "#{ENDPOINT}/v1/reestr/sgtin/filter"
      headers =
      {
        'Content-Type' => 'application/json',  'Authorization' => "token #{@token.token}"
      }

      body =
        {
          'start_from' => start,
          'count' => step,
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

    body = { 'code' => code, 'signature' => signed_code }

    request_token = request_to_api(:post, url, headers, body)

    puts request_token['token']
    puts request_token['life_time']

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

      @token.update_attribute(:last_operation_time, Time.now)
    rescue
      abort 'Не удалось подключиться к API'
    end

    abort "#{result['error_description'] || result['error']}" unless result.code == 200

    result
  end
end
