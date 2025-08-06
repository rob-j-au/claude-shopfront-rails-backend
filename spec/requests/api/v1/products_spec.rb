require 'swagger_helper'

RSpec.describe 'api/v1/products', type: :request do
  path '/api/v1/products' do
    get('List all products') do
      tags 'Products'
      description 'Retrieve all products with pagination, filtering, and search'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number (default: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page (default: 10, max: 100)'
      parameter name: :category, in: :query, type: :string, required: false, description: 'Filter by product category'
      parameter name: :search, in: :query, type: :string, required: false, description: 'Search products by name'
      
      response(200, 'Successful response') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     products: {
                       type: :array,
                       items: { '$ref' => '#/components/schemas/Product' }
                     },
                     pagination: {
                       type: :object,
                       properties: {
                         current_page: { type: :integer, description: 'Current page number' },
                         per_page: { type: :integer, description: 'Items per page' },
                         total_pages: { type: :integer, description: 'Total number of pages' },
                         total_count: { type: :integer, description: 'Total number of items' },
                         has_next_page: { type: :boolean, description: 'Whether there is a next page' },
                         has_prev_page: { type: :boolean, description: 'Whether there is a previous page' }
                       },
                       required: %w[current_page per_page total_pages total_count has_next_page has_prev_page]
                     }
                   },
                   required: %w[products pagination]
                 }
               },
               required: %w[data]

        run_test!
      end
    end

    post('create product') do
      tags 'Products'
      description 'Create a new product'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, description: 'Product name' },
              description: { type: :string, description: 'Product description' },
              price: { type: :number, format: :float, description: 'Product price' },
              stock_quantity: { type: :integer, description: 'Available stock' },
              category: { type: :string, description: 'Product category' },
              sku: { type: :string, description: 'Stock Keeping Unit' }
            },
            required: %w[name price stock_quantity category sku]
          }
        },
        required: %w[product]
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end

      response(401, 'unauthorized') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Product ID'

    get('show product') do
      tags 'Products'
      description 'Retrieve a specific product'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, description: 'Product ID' },
                     name: { type: :string, description: 'Product name' },
                     description: { type: :string, description: 'Product description' },
                     price: { type: :number, format: :float, description: 'Product price' },
                     stock_quantity: { type: :integer, description: 'Available stock' },
                     category: { type: :string, description: 'Product category' },
                     sku: { type: :string, description: 'Stock Keeping Unit' },
                     formatted_price: { type: :string, description: 'Formatted price with currency' }
                   },
                   required: %w[id name price stock_quantity category sku]
                 }
               },
               required: %w[data]

        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    put('update product') do
      tags 'Products'
      description 'Update a product'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, description: 'Product name' },
              description: { type: :string, description: 'Product description' },
              price: { type: :number, format: :float, description: 'Product price' },
              stock_quantity: { type: :integer, description: 'Available stock' },
              category: { type: :string, description: 'Product category' },
              sku: { type: :string, description: 'Stock Keeping Unit' }
            }
          }
        },
        required: %w[product]
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

    delete('delete product') do
      tags 'Products'
      description 'Delete a product'
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
