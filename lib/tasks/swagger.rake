namespace :swagger do
  desc "Generate Swagger documentation"
  task generate: :environment do
    require 'yaml'
    
    swagger_doc = {
      openapi: '3.0.1',
      info: {
        title: 'Shopfront API',
        version: 'v1',
        description: 'A modern e-commerce Rails API with token-based authentication',
        contact: {
          name: 'API Support',
          email: 'support@shopfront.com'
        }
      },
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        },
        {
          url: 'https://api.shopfront.com',
          description: 'Production server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
            description: 'Enter your API token'
          },
          apiKeyAuth: {
            type: 'apiKey',
            in: 'header',
            name: 'X-API-Token',
            description: 'API token in X-API-Token header'
          }
        },
        schemas: {
          Error: {
            type: 'object',
            properties: {
              error: {
                type: 'string',
                description: 'Error message'
              }
            },
            required: ['error']
          },
          Success: {
            type: 'object',
            properties: {
              data: {
                type: 'object',
                description: 'Response data'
              },
              message: {
                type: 'string',
                description: 'Success message'
              }
            },
            required: ['data']
          },
          Product: {
            type: 'object',
            properties: {
              id: { type: 'string', description: 'Product ID' },
              name: { type: 'string', description: 'Product name' },
              description: { type: 'string', description: 'Product description' },
              price: { type: 'number', format: 'float', description: 'Product price' },
              stock_quantity: { type: 'integer', description: 'Available stock' },
              category: { type: 'string', description: 'Product category' },
              sku: { type: 'string', description: 'Stock Keeping Unit' },
              formatted_price: { type: 'string', description: 'Formatted price with currency' }
            },
            required: %w[id name price stock_quantity category sku]
          },
          Order: {
            type: 'object',
            properties: {
              id: { type: 'string', description: 'Order ID' },
              order_number: { type: 'string', description: 'Order number' },
              status: { type: 'string', description: 'Order status', enum: %w[pending processing shipped delivered cancelled] },
              total: { type: 'string', description: 'Order total' },
              total_amount: { type: 'string', description: 'Order total amount' },
              created_at: { type: 'string', format: 'date-time', description: 'Order creation timestamp' },
              line_items: {
                type: 'array',
                items: { '$ref' => '#/components/schemas/LineItem' }
              }
            },
            required: %w[id order_number status total total_amount]
          },
          LineItem: {
            type: 'object',
            properties: {
              id: { type: 'string', description: 'Line item ID' },
              quantity: { type: 'integer', description: 'Item quantity' },
              price: { type: 'string', description: 'Item price' },
              product: { '$ref' => '#/components/schemas/Product' }
            }
          },
          User: {
            type: 'object',
            properties: {
              id: { type: 'string', description: 'User ID' },
              email: { type: 'string', description: 'User email' },
              first_name: { type: 'string', description: 'User first name' },
              last_name: { type: 'string', description: 'User last name' },
              full_name: { type: 'string', description: 'User full name' },
              created_at: { type: 'string', format: 'date-time', description: 'User creation timestamp' }
            },
            required: %w[id email first_name last_name full_name]
          },
          ApiToken: {
            type: 'object',
            properties: {
              api_token: { type: 'string', description: '32-character API token' },
              expires_at: { type: 'string', format: 'date-time', description: 'Token expiration timestamp' },
              user: { '$ref' => '#/components/schemas/User' }
            },
            required: %w[api_token expires_at user]
          }
        }
      },
      paths: {
        '/api/v1/products' => {
          get: {
            tags: ['Products'],
            summary: 'List all products',
            description: 'Retrieve all products',
            responses: {
              '200' => {
                description: 'Successful response',
                content: {
                  'application/json' => {
                    schema: {
                      type: 'object',
                      properties: {
                        data: {
                          type: 'array',
                          items: { '$ref' => '#/components/schemas/Product' }
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          post: {
            tags: ['Products'],
            summary: 'Create a new product',
            description: 'Create a new product (authentication required)',
            security: [
              { bearerAuth: [] },
              { apiKeyAuth: [] }
            ],
            requestBody: {
              required: true,
              content: {
                'application/json' => {
                  schema: {
                    type: 'object',
                    properties: {
                      product: {
                        type: 'object',
                        properties: {
                          name: { type: 'string' },
                          description: { type: 'string' },
                          price: { type: 'number', format: 'float' },
                          stock_quantity: { type: 'integer' },
                          category: { type: 'string' },
                          sku: { type: 'string' }
                        },
                        required: %w[name price stock_quantity category sku]
                      }
                    }
                  }
                }
              }
            },
            responses: {
              '200' => {
                description: 'Product created successfully',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Success' }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              },
              '422' => {
                description: 'Validation error',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          }
        },
        '/api/v1/products/{id}' => {
          get: {
            tags: ['Products'],
            summary: 'Get a product',
            description: 'Retrieve a specific product by ID',
            parameters: [
              {
                name: 'id',
                in: 'path',
                required: true,
                schema: { type: 'string' },
                description: 'Product ID'
              }
            ],
            responses: {
              '200' => {
                description: 'Successful response',
                content: {
                  'application/json' => {
                    schema: {
                      type: 'object',
                      properties: {
                        data: { '$ref' => '#/components/schemas/Product' }
                      }
                    }
                  }
                }
              },
              '404' => {
                description: 'Product not found',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          },
          put: {
            tags: ['Products'],
            summary: 'Update a product',
            description: 'Update a product (authentication required)',
            security: [
              { bearerAuth: [] },
              { apiKeyAuth: [] }
            ],
            parameters: [
              {
                name: 'id',
                in: 'path',
                required: true,
                schema: { type: 'string' },
                description: 'Product ID'
              }
            ],
            requestBody: {
              required: true,
              content: {
                'application/json' => {
                  schema: {
                    type: 'object',
                    properties: {
                      product: {
                        type: 'object',
                        properties: {
                          name: { type: 'string' },
                          description: { type: 'string' },
                          price: { type: 'number', format: 'float' },
                          stock_quantity: { type: 'integer' },
                          category: { type: 'string' },
                          sku: { type: 'string' }
                        }
                      }
                    }
                  }
                }
              }
            },
            responses: {
              '200' => {
                description: 'Product updated successfully',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Success' }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              },
              '404' => {
                description: 'Product not found',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          },
          delete: {
            tags: ['Products'],
            summary: 'Delete a product',
            description: 'Delete a product (authentication required)',
            security: [
              { bearerAuth: [] },
              { apiKeyAuth: [] }
            ],
            parameters: [
              {
                name: 'id',
                in: 'path',
                required: true,
                schema: { type: 'string' },
                description: 'Product ID'
              }
            ],
            responses: {
              '200' => {
                description: 'Product deleted successfully',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Success' }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              },
              '404' => {
                description: 'Product not found',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          }
        },
        '/api/v1/tokens' => {
          post: {
            tags: ['Authentication'],
            summary: 'Generate API token',
            description: 'Generate a new API token (requires session authentication)',
            responses: {
              '200' => {
                description: 'Token generated successfully',
                content: {
                  'application/json' => {
                    schema: {
                      type: 'object',
                      properties: {
                        data: { '$ref' => '#/components/schemas/ApiToken' },
                        message: { type: 'string' }
                      }
                    }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          },
          delete: {
            tags: ['Authentication'],
            summary: 'Revoke API token',
            description: 'Revoke the current API token',
            security: [
              { bearerAuth: [] },
              { apiKeyAuth: [] }
            ],
            responses: {
              '200' => {
                description: 'Token revoked successfully',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Success' }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          }
        },
        '/api/v1/tokens/verify' => {
          get: {
            tags: ['Authentication'],
            summary: 'Verify API token',
            description: 'Verify the validity of the current API token',
            security: [
              { bearerAuth: [] },
              { apiKeyAuth: [] }
            ],
            responses: {
              '200' => {
                description: 'Token is valid',
                content: {
                  'application/json' => {
                    schema: {
                      type: 'object',
                      properties: {
                        data: {
                          type: 'object',
                          properties: {
                            valid: { type: 'boolean' },
                            expires_at: { type: 'string', format: 'date-time' },
                            user: { '$ref' => '#/components/schemas/User' }
                          }
                        },
                        message: { type: 'string' }
                      }
                    }
                  }
                }
              },
              '401' => {
                description: 'Unauthorized',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/Error' }
                  }
                }
              }
            }
          }
        }
      }
    }
    
    # Create swagger directory if it doesn't exist
    swagger_dir = Rails.root.join('swagger')
    v1_dir = swagger_dir.join('v1')
    FileUtils.mkdir_p(v1_dir)
    
    # Write the swagger documentation in JSON format
    File.open(v1_dir.join('swagger.json'), 'w') do |file|
      file.write(swagger_doc.to_json)
    end
    
    puts "Swagger documentation generated at #{swagger_dir}/v1/swagger.json"
  end
end
