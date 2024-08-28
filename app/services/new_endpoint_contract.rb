class NewEndpointContract < Dry::Validation::Contract
  # TODO: Find a way to check field out of schema without headers values
  # config.validate_keys = true

  params do
    required(:data).hash do
      required(:type).filled(:string)
      required(:attributes).hash do
        required(:verb).filled(:string)
        required(:path).filled(:string)
        required(:response).hash do
          required(:headers).value(:hash)
          required(:code).filled(:integer)
          required(:body).value(:string)
        end
      end
    end
  end

  rule('data.type') do
    key.failure('this type is not supported') unless value == 'endpoints'
  end

  rule('data.attributes.verb') do
    key.failure('verb is invalid') unless %w[GET HEAD POST PUT DELETE CONNECT OPTIONS TRACE].include?(value)
  end

  rule('data.attributes.response.code') do
    key.failure('must be in range 100-599') unless value.between?(100, 599)
  end
end