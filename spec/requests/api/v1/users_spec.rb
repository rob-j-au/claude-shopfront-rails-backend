require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get('list users') do
      tags 'Users'
      description 'Retrieve all users (admin only)'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, description: 'User ID' },
                       email: { type: :string, description: 'User email' },
                       first_name: { type: :string, description: 'User first name' },
                       last_name: { type: :string, description: 'User last name' },
                       full_name: { type: :string, description: 'User full name' },
                       created_at: { type: :string, format: 'date-time', description: 'User creation timestamp' }
                     },
                     required: %w[id email first_name last_name full_name]
                   }
                 }
               },
               required: %w[data]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(403, 'forbidden') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    post('create user') do
      tags 'Users'
      description 'Create a new user account'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email, description: 'User email' },
              password: { type: :string, description: 'User password', minimum: 6 },
              password_confirmation: { type: :string, description: 'Password confirmation' },
              first_name: { type: :string, description: 'User first name' },
              last_name: { type: :string, description: 'User last name' }
            },
            required: %w[email password password_confirmation first_name last_name]
          }
        },
        required: %w[user]
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/users/profile' do
    get('show user profile') do
      tags 'Users'
      description 'Retrieve the authenticated user profile'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, description: 'User ID' },
                     email: { type: :string, description: 'User email' },
                     first_name: { type: :string, description: 'User first name' },
                     last_name: { type: :string, description: 'User last name' },
                     full_name: { type: :string, description: 'User full name' },
                     created_at: { type: :string, format: 'date-time', description: 'User creation timestamp' }
                   },
                   required: %w[id email first_name last_name full_name]
                 }
               },
               required: %w[data]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'User ID'

    get('show user') do
      tags 'Users'
      description 'Retrieve a specific user'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, description: 'User ID' },
                     email: { type: :string, description: 'User email' },
                     first_name: { type: :string, description: 'User first name' },
                     last_name: { type: :string, description: 'User last name' },
                     full_name: { type: :string, description: 'User full name' },
                     created_at: { type: :string, format: 'date-time', description: 'User creation timestamp' }
                   },
                   required: %w[id email first_name last_name full_name]
                 }
               },
               required: %w[data]

        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    put('update user') do
      tags 'Users'
      description 'Update user information'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email, description: 'User email' },
              first_name: { type: :string, description: 'User first name' },
              last_name: { type: :string, description: 'User last name' }
            }
          }
        },
        required: %w[user]
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete('delete user') do
      tags 'Users'
      description 'Delete a user account'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
