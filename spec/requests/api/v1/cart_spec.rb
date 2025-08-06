require 'swagger_helper'

RSpec.describe 'api/v1/cart', type: :request do
  path '/api/v1/cart' do
    get('show cart') do
      tags 'Cart'
      description 'Retrieve the current cart contents'
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     items: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           product_id: { type: :string, description: 'Product ID' },
                           quantity: { type: :integer, description: 'Item quantity' },
                           product: {
                             type: :object,
                             properties: {
                               id: { type: :string, description: 'Product ID' },
                               name: { type: :string, description: 'Product name' },
                               price: { type: :number, format: :float, description: 'Product price' },
                               sku: { type: :string, description: 'Product SKU' }
                             }
                           }
                         }
                       }
                     },
                     total: { type: :number, format: :float, description: 'Cart total' }
                   }
                 }
               },
               required: %w[data]

        run_test!
      end
    end

    post('add to cart') do
      tags 'Cart'
      description 'Add a product to the cart'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cart_item, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string, description: 'Product ID' },
          quantity: { type: :integer, description: 'Item quantity', minimum: 1 }
        },
        required: %w[product_id quantity]
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
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

    patch('update cart') do
      tags 'Cart'
      description 'Update cart item quantity'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cart_item, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :string, description: 'Product ID' },
          quantity: { type: :integer, description: 'New quantity', minimum: 1 }
        },
        required: %w[product_id quantity]
      }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
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

    delete('remove from cart') do
      tags 'Cart'
      description 'Remove a product from the cart'
      produces 'application/json'

      parameter name: :product_id, in: :query, type: :string, description: 'Product ID to remove'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/api/v1/cart/clear' do
    delete('clear cart') do
      tags 'Cart'
      description 'Clear all items from the cart'
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/Success'
        run_test!
      end
    end
  end
end
