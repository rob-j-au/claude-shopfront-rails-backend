require 'swagger_helper'

RSpec.describe 'api/v1/tokens', type: :request do
  path '/api/v1/tokens' do
    post('generate API token') do
      tags 'Authentication'
      description 'Generate a new API token for authenticated user'
      consumes 'application/json'
      produces 'application/json'
      
      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     api_token: { 
                       type: :string, 
                       description: '32-character API token',
                       example: 'abc123def456ghi789jkl012mno345pq'
                     },
                     expires_at: { 
                       type: :string, 
                       format: 'date-time',
                       description: 'Token expiration timestamp',
                       example: '2024-02-19T10:30:00.000Z'
                     },
                     user: {
                       type: :object,
                       properties: {
                         id: { type: :string, description: 'User ID' },
                         email: { type: :string, description: 'User email' },
                         full_name: { type: :string, description: 'User full name' }
                       },
                       required: %w[id email full_name]
                     }
                   },
                   required: %w[api_token expires_at user]
                 },
                 message: { 
                   type: :string,
                   example: 'API token generated successfully'
                 }
               },
               required: %w[data message]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete('revoke API token') do
      tags 'Authentication'
      description 'Revoke the current API token'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: { type: :object },
                 message: { 
                   type: :string,
                   example: 'API token revoked successfully'
                 }
               },
               required: %w[data message]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/tokens/verify' do
    get('verify API token') do
      tags 'Authentication'
      description 'Verify the validity of the current API token'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     valid: { 
                       type: :boolean,
                       description: 'Token validity status',
                       example: true
                     },
                     expires_at: { 
                       type: :string, 
                       format: 'date-time',
                       description: 'Token expiration timestamp',
                       example: '2024-02-19T10:30:00.000Z'
                     },
                     user: {
                       type: :object,
                       properties: {
                         id: { type: :string, description: 'User ID' },
                         email: { type: :string, description: 'User email' },
                         full_name: { type: :string, description: 'User full name' }
                       },
                       required: %w[id email full_name]
                     }
                   },
                   required: %w[valid expires_at user]
                 },
                 message: { 
                   type: :string,
                   example: 'Token is valid'
                 }
               },
               required: %w[data message]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
