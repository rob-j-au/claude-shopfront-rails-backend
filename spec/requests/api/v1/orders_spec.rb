require 'swagger_helper'

RSpec.describe 'api/v1/orders', type: :request do
  path '/api/v1/orders' do
    get('list orders') do
      tags 'Orders'
      description 'Retrieve all orders for the authenticated user'
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
                       id: { type: :string, description: 'Order ID' },
                       order_number: { type: :string, description: 'Order number' },
                       status: { type: :string, description: 'Order status', enum: %w[pending processing shipped delivered cancelled] },
                       total: { type: :string, description: 'Order total' },
                       total_amount: { type: :string, description: 'Order total amount' },
                       created_at: { type: :string, format: 'date-time', description: 'Order creation timestamp' },
                       line_items: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             id: { type: :string, description: 'Line item ID' },
                             quantity: { type: :integer, description: 'Item quantity' },
                             price: { type: :string, description: 'Item price' },
                             product: {
                               type: :object,
                               properties: {
                                 id: { type: :string, description: 'Product ID' },
                                 name: { type: :string, description: 'Product name' },
                                 sku: { type: :string, description: 'Product SKU' }
                               }
                             }
                           }
                         }
                       }
                     },
                     required: %w[id order_number status total total_amount]
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
    end

    post('create order') do
      tags 'Orders'
      description 'Create a new order'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              status: { type: :string, description: 'Order status', enum: %w[pending processing shipped delivered cancelled] }
            }
          },
          line_items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :string, description: 'Product ID' },
                quantity: { type: :integer, description: 'Item quantity', minimum: 1 }
              },
              required: %w[product_id quantity]
            }
          }
        },
        required: %w[line_items]
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

  path '/api/v1/orders/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Order ID'

    get('show order') do
      tags 'Orders'
      description 'Retrieve a specific order'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string, description: 'Order ID' },
                     order_number: { type: :string, description: 'Order number' },
                     status: { type: :string, description: 'Order status' },
                     total: { type: :string, description: 'Order total' },
                     total_amount: { type: :string, description: 'Order total amount' },
                     created_at: { type: :string, format: 'date-time', description: 'Order creation timestamp' },
                     line_items: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :string, description: 'Line item ID' },
                           quantity: { type: :integer, description: 'Item quantity' },
                           price: { type: :string, description: 'Item price' },
                           product: {
                             type: :object,
                             properties: {
                               id: { type: :string, description: 'Product ID' },
                               name: { type: :string, description: 'Product name' },
                               sku: { type: :string, description: 'Product SKU' }
                             }
                           }
                         }
                       }
                     }
                   },
                   required: %w[id order_number status total total_amount]
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

    put('update order') do
      tags 'Orders'
      description 'Update an order status'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: [], apiKeyAuth: []]

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              status: { type: :string, description: 'Order status', enum: %w[pending processing shipped delivered cancelled] }
            },
            required: %w[status]
          }
        },
        required: %w[order]
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

    delete('delete order') do
      tags 'Orders'
      description 'Delete an order'
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
