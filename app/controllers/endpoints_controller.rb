class EndpointsController < ApplicationController
  rescue_from StandardError, with: :internal_server_error

  before_action :check_content_type, only: [:index, :create, :update, :destroy]
  before_action :find_endpoint, only: [:update, :destroy]
  before_action :check_contract, only: [:create, :update]
  before_action :check_matching_existing_endpoint, only: [:create, :update]

  attr_reader :parameters, :build_endpoint

  def index
    @endpoints = Endpoint.all

    respond_to do |format|
      format.jsonapi { render json: { data: @endpoints.map { |endpoint| serialize_endpoint(endpoint) } } }
    end
  end

  def create
    endpoint = Endpoint.create!(build_endpoint)

    response.headers['Location'] = build_endpoint[:path]

    respond_to do |format|
      format.jsonapi {  render json: { data: serialize_endpoint(endpoint) }, status: :created }
    end
  end

  def update
    @endpoint.update!(build_endpoint)

    respond_to do |format|
      format.jsonapi { render json: { data: serialize_endpoint(@endpoint) } }
    end
  end

  def destroy
    @endpoint.destroy

    head :no_content
  end

  # For rendering mock endpoints
  def echo_endpoint
    endpoint = Endpoint.find_by(verb: request.method, path: request.path)

    # Check if body can be parsed as json
    body = parse_if_json(endpoint.body)

    # TODO: Add possibility to dynamically render based on content type stored in db
    if endpoint
      render json: body, status: endpoint.code, headers: endpoint.headers
    else
      render json: { errors: [{ code: 'not_found', detail: "Requested page #{request.path} does not exist" }] }, status: :not_found
    end
  end

  # Handling internal errors
  def internal_server_error
    render json: { errors: [{ code: 'internal_server_error', detail: 'Internal Server Error' }] }, status: :internal_server_error
  end

  private

  # Allow only accepted content type
  def check_content_type
    unless %w[application/vnd.api+json].include?(request.accept)
      head :unsupported_media_type
    end
  end

  # Check if endpoint with such id exists
  def find_endpoint
    @endpoint = Endpoint.find_by(id: params[:id])

    unless @endpoint
      render json: { errors: [{ code: 'not_found', detail: "Requested Endpoint with ID #{params[:id]} does not exist" }] }, status: :not_found
    end
  end

  # Validate body using schema
  def check_contract
    validation = NewEndpointContract.new.call(parameters)

    if validation.failure?
      render json: { errors: validation.errors.to_h }, status: :unprocessable_entity
    end
  end

  # Prevent internal error with saving the same request
  def check_matching_existing_endpoint
    existing_endpoint = Endpoint.find_by(verb: build_endpoint[:verb], path: build_endpoint[:path])
    matching_condition = existing_endpoint.present?

    # Check if existing_endpoint id is not the same as params id for update action to not block update request
    matching_condition = matching_condition && params[:id].to_i != existing_endpoint.id if params['action'] == 'update'

    if matching_condition
       render json: { errors:  [{ code: 'validation_error', detail: 'Requested Endpoint already exist' }] }, status: :unprocessable_entity
    end
  end

  # Get params-like parameters from request body
  def parameters
    @parameters ||= JSON.parse(request.body.read)
  end

  def parse_if_json(string)
    JSON.parse(string)
  rescue JSON::ParserError
    return string
  end

  def build_endpoint
    @build_endpoint ||= {
      verb: parameters.dig('data', 'attributes', 'verb'),
      path: parameters.dig('data', 'attributes', 'path'),
      code: parameters.dig('data', 'attributes', 'response', 'code'),
      headers: parameters.dig('data', 'attributes', 'response', 'headers'),
      body: parameters.dig('data', 'attributes', 'response', 'body')
    }
  end

  def serialize_endpoint(endpoint)
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
  end
end