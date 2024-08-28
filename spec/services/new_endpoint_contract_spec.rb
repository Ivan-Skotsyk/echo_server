require 'rails_helper'

RSpec.describe NewEndpointContract do
  let(:contract) { described_class.new }

  describe 'validations' do
    let(:valid_params) do
      {
        data: {
          type: 'endpoints',
          attributes: {
            verb: 'GET',
            path: '/example',
            response: {
              code: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: '{ "message": "Hello, world" }'
            }
          }
        }
      }
    end

    context 'with valid parameters' do
      it 'passes validation' do
        result = contract.call(valid_params)
        expect(result.errors).to be_empty
      end
    end

    context 'with invalid type' do
      it 'fails validation' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:type] = 'invalid_type'

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { type: ['this type is not supported'] })
      end
    end

    context 'with invalid HTTP verb' do
      it 'fails validation' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes][:verb] = 'INVALID_VERB'

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { verb: ['verb is invalid'] } })
      end
    end

    context 'with out-of-range response code' do
      it 'fails validation when code is below 100' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes][:response][:code] = 99

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { response: { code: ['must be in range 100-599'] } } })
      end

      it 'fails validation when code is above 599' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes][:response][:code] = 600

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { response: { code: ['must be in range 100-599'] } } })
      end
    end

    context 'with missing required fields' do
      it 'fails validation when verb is missing' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes].delete(:verb)

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { verb: ['is missing'] } })
      end

      it 'fails validation when path is missing' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes].delete(:path)

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { path: ['is missing'] } })
      end

      it 'fails validation when response is missing' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes].delete(:response)

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { response: ['is missing'] } })
      end
    end

    context 'with invalid headers structure' do
      it 'fails validation when headers is not a hash' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes][:response][:headers] = 'not_a_hash'

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { response: { headers: ['must be a hash'] } } })
      end
    end

    context 'with invalid body' do
      it 'fails validation when body is not a string' do
        invalid_params = valid_params.deep_dup
        invalid_params[:data][:attributes][:response][:body] = { invalid: 'data' }

        result = contract.call(invalid_params)
        expect(result.errors.to_h).to include(data: { attributes: { response: { body: ['must be a string'] } } })
      end
    end
  end
end