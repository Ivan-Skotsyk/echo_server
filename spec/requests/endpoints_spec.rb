require 'rails_helper'

RSpec.describe "Endpoints API", type: :request do
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

  let(:invalid_params) do
    {
      data: {
        type: 'endpoints',
        attributes: {
          verb: 'INVALID_VERB',
          path: '/example',
          response: {
            code: 600,
            headers: { 'Content-Type' => 'application/xml' },
            body: '{ "message": "Hello, world" }'
          }
        }
      }
    }
  end
  let!(:endpoint) do
    Endpoint.create!(
      verb: 'POST',
      path: '/example/',
      code: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: '{ "message": "Hello, world" }'
    )
  end

  describe 'GET /endpoints' do
    let(:expected_response) do
      {
        data: [
          {
            type: 'endpoints',
            id: endpoint.id,
            attributes: {
              verb: endpoint.verb,
              path: endpoint.path,
              response: {
                code: endpoint.code,
                headers: endpoint.headers,
                body: endpoint.body
              }
            }
          }
        ]
      }
    end

    it 'returns a list of endpoints' do
      get endpoints_path, headers: { 'Accept' => 'application/vnd.api+json' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(expected_response.to_json)
    end

    it 'returns 415 Unsupported Media Type if content type is not supported' do
      get endpoints_path, headers: { 'Accept' => 'application/xml' }

      expect(response).to have_http_status(:unsupported_media_type)
    end
  end

  describe 'POST /endpoints' do
    let(:headers) do
      { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' }
    end

    context 'with valid parameters' do
      it 'creates a new Endpoint' do
        post endpoints_path, params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:created)
      end

      it 'returns 415 Unsupported Media Type if content type is not supported' do
        post endpoints_path, params: valid_params.to_json, headers: { 'Accept' => 'application/xml' }

        expect(response).to have_http_status(:unsupported_media_type)
      end
    end

    context 'with invalid parameters' do
      it 'returns 422 Unprocessable Entity' do
        post endpoints_path, params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /endpoints/:id' do
    let(:headers) do
      { 'Content-Type' => 'application/vnd.api+json', 'Accept' => 'application/vnd.api+json' }
    end

    # TODO: Find a way to remove this mock
    before do
      allow_any_instance_of(EndpointsController).to receive(:parameters).and_return(parameters)
    end

    context 'with valid parameters' do
      let(:parameters) do
        valid_parameters = valid_params.deep_stringify_keys.deep_dup
        valid_parameters['data']['attributes']['path'] = '/updated_path'

        valid_parameters
      end

      it 'updates the requested endpoint' do
        patch endpoint_path(endpoint), headers: headers

        expect(response).to have_http_status(:ok)
        endpoint.reload
        expect(endpoint.path).to eq('/updated_path')
      end

      it 'returns 404 Not Found if endpoint does not exist' do
        patch endpoint_path('non-existent-id'), headers: { 'Accept' => 'application/vnd.api+json' }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid parameters' do
      let(:parameters) do
         invalid_params.deep_stringify_keys
      end


      it 'returns 422 Unprocessable Entity' do
        patch endpoint_path(endpoint), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /endpoints/:id' do
    it 'destroys the requested endpoint' do
      expect {
        delete endpoint_path(endpoint), headers: { 'Accept' => 'application/vnd.api+json' }
      }.to change(Endpoint, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 Not Found if endpoint does not exist' do
      delete endpoint_path('non-existent-id'), headers: { 'Accept' => 'application/vnd.api+json' }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Internal error handling' do
    it 'returns a list of endpoints' do
      expect(Endpoint).to receive(:all).and_raise(StandardError)

      get endpoints_path, headers: { 'Accept' => 'application/vnd.api+json' }

      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include('Internal Server Error')
    end
  end
end