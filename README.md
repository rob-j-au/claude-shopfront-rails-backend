# Shopfront App

A modern e-commerce Rails application with both web interface and REST API support. Built with Rails 8, MongoDB (Mongoid), and Devise authentication.

## Features

- **User Authentication**: Secure user registration and login with Devise
- **Product Management**: Browse, search, and manage products
- **Shopping Cart**: Session-based cart functionality
- **Order Management**: Create and track orders
- **REST API**: Full API support for all major features
- **Responsive Design**: Bootstrap-powered responsive UI

## Tech Stack

- **Ruby**: 3.4.1
- **Rails**: 8.0.2
- **Database**: MongoDB with Mongoid ODM
- **Authentication**: Devise
- **Frontend**: Bootstrap 5, Stimulus, Turbo
- **API**: RESTful JSON API

## Setup

### Prerequisites

- Ruby 3.4.1
- MongoDB
- Node.js (for asset compilation)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd shopfront_app
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Start MongoDB service:
   ```bash
   # On macOS with Homebrew
   brew services start mongodb-community
   
   # On Ubuntu/Debian
   sudo systemctl start mongod
   ```

4. Start the Rails server:
   ```bash
   rails server
   ```

5. Visit `http://localhost:3000` to access the web interface

## Testing

The application includes comprehensive integration tests for both the web interface and API endpoints.

### Running All Tests

To run the complete test suite:

```bash
rails test
```

### Running Specific Test Files

To run tests for specific components:

```bash
# Run all API integration tests
rails test test/integration/api/

# Run specific API endpoint tests
rails test test/integration/api/v1/products_test.rb
rails test test/integration/api/v1/users_test.rb
rails test test/integration/api/v1/orders_test.rb
rails test test/integration/api/v1/cart_test.rb

# Run model tests
rails test test/models/

# Run controller tests
rails test test/controllers/
```

### Running Tests with Verbose Output

For detailed test output:

```bash
rails test --verbose
```

### Test Coverage

The test suite covers:

- **API Authentication**: User registration, login, and session management
- **Product Management**: CRUD operations, validation, and authorization
- **Order Processing**: Order creation, line items, total calculations
- **Cart Functionality**: Adding/removing items, session management
- **Error Handling**: Invalid requests, authentication failures, validation errors
- **Authorization**: User permissions and access control

### Test Database

Tests use a separate MongoDB test database. The test environment is automatically configured to:

- Use `shopfront_app_test` database
- Clean up data between tests
- Handle Mongoid-specific validations and constraints

### Prerequisites for Testing

Ensure MongoDB is running before executing tests:

```bash
# On macOS with Homebrew
brew services start mongodb-community

# On Ubuntu/Debian
sudo systemctl start mongod
```

## Web Interface

The web interface provides:

- **Home Page**: Welcome page with navigation
- **Products**: Browse and view product details
- **Cart**: Add/remove items, update quantities
- **User Registration/Login**: Secure authentication
- **Orders**: View order history (authenticated users)

## API Documentation

The Shopfront App provides a comprehensive REST API at `/api/v1/`. All API responses are in JSON format.

### Base URL

```
http://localhost:3000/api/v1
```

### Authentication

The API supports both **token-based authentication** (recommended for API clients) and **session-based authentication** (for web browsers).

#### Token-Based Authentication (Recommended)

For API clients, use token-based authentication for better security and scalability.

**Step 1: Generate an API Token**

First, authenticate via session to get an API token:

```bash
# Sign in via session
curl -X POST http://localhost:3000/users/sign_in \
  -d "user[email]=your@email.com&user[password]=yourpassword" \
  -c cookies.txt

# Generate API token
curl -X POST http://localhost:3000/api/v1/tokens \
  -b cookies.txt
```

**Response:**
```json
{
  "data": {
    "api_token": "your_32_character_token_here",
    "expires_at": "2024-02-19T10:30:00.000Z",
    "user": {
      "id": "user_id",
      "email": "your@email.com",
      "full_name": "Your Name"
    }
  },
  "message": "API token generated successfully"
}
```

**Step 2: Use the API Token**

Include the token in your API requests using one of these methods:

**Option 1: Authorization Header (Recommended)**
```bash
curl -H "Authorization: Bearer your_token_here" \
  http://localhost:3000/api/v1/products
```

**Option 2: X-API-Token Header**
```bash
curl -H "X-API-Token: your_token_here" \
  http://localhost:3000/api/v1/products
```

**Option 3: URL Parameter**
```bash
curl "http://localhost:3000/api/v1/products?api_token=your_token_here"
```

#### Token Management

**Verify Token**
```bash
curl -H "Authorization: Bearer your_token" \
  http://localhost:3000/api/v1/tokens/verify
```

**Revoke Token**
```bash
curl -X DELETE -H "Authorization: Bearer your_token" \
  http://localhost:3000/api/v1/tokens
```

#### Session-Based Authentication

For web browsers or if you prefer session-based authentication, you must first log in through the web interface or maintain session cookies. The API will automatically fall back to session authentication if no valid token is provided.

### Products API

#### List All Products
```http
GET /api/v1/products
```

**Response:**
```json
{
  "data": [
    {
      "id": "product_id",
      "name": "Product Name",
      "description": "Product description",
      "price": 29.99,
      "stock_quantity": 100,
      "category": "Electronics",
      "formatted_price": "$29.99"
    }
  ]
}
```

#### Get Single Product
```http
GET /api/v1/products/:id
```

#### Create Product (Authentication Required)
```http
POST /api/v1/products
Content-Type: application/json

{
  "product": {
    "name": "New Product",
    "description": "Product description",
    "price": 29.99,
    "stock_quantity": 50,
    "category": "Electronics"
  }
}
```

#### Update Product (Authentication Required)
```http
PUT /api/v1/products/:id
Content-Type: application/json

{
  "product": {
    "name": "Updated Product Name",
    "price": 39.99
  }
}
```

#### Delete Product (Authentication Required)
```http
DELETE /api/v1/products/:id
```

### Users API

#### Get User Profile (Authentication Required)
```http
GET /api/v1/users/profile
```

**Response:**
```json
{
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

#### Create User
```http
POST /api/v1/users
Content-Type: application/json

{
  "user": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

#### Update User (Authentication Required)
```http
PUT /api/v1/users/:id
Content-Type: application/json

{
  "user": {
    "first_name": "Jane",
    "last_name": "Smith"
  }
}
```

### Cart API

#### Get Cart Contents
```http
GET /api/v1/cart
```

**Response:**
```json
{
  "data": {
    "items": [
      {
        "product": {
          "id": "product_id",
          "name": "Product Name",
          "price": 29.99,
          "formatted_price": "$29.99"
        },
        "quantity": 2,
        "total": 59.98
      }
    ],
    "total": 59.98,
    "item_count": 2
  }
}
```

#### Add Item to Cart
```http
POST /api/v1/cart/add
Content-Type: application/json

{
  "product_id": "product_id",
  "quantity": 2
}
```

#### Update Cart Item
```http
PATCH /api/v1/cart/update
Content-Type: application/json

{
  "product_id": "product_id",
  "quantity": 3
}
```

#### Remove Item from Cart
```http
DELETE /api/v1/cart/remove
Content-Type: application/json

{
  "product_id": "product_id"
}
```

#### Clear Cart
```http
DELETE /api/v1/cart/clear
```

### Orders API (Authentication Required)

#### List User Orders
```http
GET /api/v1/orders
```

**Response:**
```json
{
  "data": [
    {
      "id": "order_id",
      "status": "pending",
      "total": 59.98,
      "created_at": "2024-01-01T00:00:00Z",
      "order_items": [
        {
          "product": {
            "name": "Product Name",
            "price": 29.99
          },
          "quantity": 2,
          "price": 29.99
        }
      ]
    }
  ]
}
```

#### Get Single Order
```http
GET /api/v1/orders/:id
```

#### Create Order
```http
POST /api/v1/orders
Content-Type: application/json

{
  "order": {
    "shipping_address": "123 Main St, City, State 12345",
    "billing_address": "123 Main St, City, State 12345",
    "order_items": [
      {
        "product_id": "product_id",
        "quantity": 2
      }
    ]
  }
}
```

#### Update Order Status
```http
PUT /api/v1/orders/:id
Content-Type: application/json

{
  "order": {
    "status": "shipped"
  }
}
```

### Error Responses

All API endpoints return consistent error responses:

```json
{
  "error": "Error message describing what went wrong"
}
```

Common HTTP status codes:
- `200 OK`: Success
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors

## API Usage Examples

### Using cURL

```bash
# Get all products
curl -X GET http://localhost:3000/api/v1/products

# Add item to cart
curl -X POST http://localhost:3000/api/v1/cart/add \
  -H "Content-Type: application/json" \
  -d '{"product_id":"product_id","quantity":1}'

# Get cart contents
curl -X GET http://localhost:3000/api/v1/cart
```

### Using JavaScript (Fetch API)

```javascript
// Get all products
fetch('/api/v1/products')
  .then(response => response.json())
  .then(data => console.log(data));

// Add item to cart
fetch('/api/v1/cart/add', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    product_id: 'product_id',
    quantity: 1
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

## Interactive API Documentation (Swagger)

The Shopfront API includes comprehensive interactive documentation powered by Swagger/OpenAPI 3.0.

### Accessing Swagger UI

1. **Start the Rails server:**
   ```bash
   rails server
   ```

2. **Open your browser and navigate to:**
   ```
   http://localhost:3000/api-docs
   ```

### Features of the Swagger Documentation

#### 🔍 **Explore All Endpoints**
- Browse all available API endpoints organized by category
- View detailed request/response schemas
- See required and optional parameters
- Understand authentication requirements

#### 🧪 **Interactive Testing**
- Test API endpoints directly from the browser
- No need for external tools like Postman or curl
- Real-time request/response examples
- Built-in authentication support

#### 🔐 **Authentication Setup**

**For Token-Based Authentication:**

1. **Generate an API token first** (using session authentication):
   - Sign in to the web interface at `http://localhost:3000`
   - Or use curl to get a session and generate token:
     ```bash
     # Sign in via session
     curl -X POST http://localhost:3000/users/sign_in \
       -d "user[email]=your@email.com&user[password]=yourpassword" \
       -c cookies.txt
     
     # Generate API token
     curl -X POST http://localhost:3000/api/v1/tokens \
       -b cookies.txt
     ```

2. **In Swagger UI, click the "Authorize" button** (🔒 icon at the top)

3. **Choose your authentication method:**
   - **Bearer Token**: Enter `your_token_here` in the "bearerAuth" field
   - **API Key**: Enter `your_token_here` in the "apiKeyAuth" field

4. **Click "Authorize"** - you're now authenticated for all protected endpoints!

#### 📚 **Documentation Categories**

**Authentication**
- `POST /api/v1/tokens` - Generate API token
- `DELETE /api/v1/tokens` - Revoke API token
- `GET /api/v1/tokens/verify` - Verify token validity

**Products**
- `GET /api/v1/products` - List all products
- `POST /api/v1/products` - Create product (auth required)
- `GET /api/v1/products/{id}` - Get specific product
- `PUT /api/v1/products/{id}` - Update product (auth required)
- `DELETE /api/v1/products/{id}` - Delete product (auth required)

**Orders**
- Complete order management with line items
- Order status updates
- User-specific order filtering

**Cart**
- Add/remove items from cart
- Update quantities
- Clear cart functionality

**Users**
- User profile management
- Account creation and updates

### Using Swagger for Development

#### 🚀 **Quick API Testing Workflow**

1. **Open Swagger UI** at `http://localhost:3000/api-docs`
2. **Authenticate** using the steps above
3. **Try the "List Products" endpoint** to see sample data
4. **Create a new product** using the POST endpoint
5. **Test other endpoints** like cart operations or orders

#### 📝 **Understanding Request/Response Formats**

- **Click on any endpoint** to expand its documentation
- **View the "Model" tab** to see the exact JSON structure expected
- **Use "Try it out"** to see live examples with your data
- **Check response codes** to understand success/error scenarios

#### 🔄 **Regenerating Documentation**

If you make changes to the API, regenerate the Swagger documentation:

```bash
rails swagger:generate
```

The documentation will be updated at `swagger/v1/swagger.yaml` and automatically reflected in the Swagger UI.

### Swagger vs Manual Testing

| Feature | Swagger UI | Manual (curl/Postman) |
|---------|------------|------------------------|
| **Ease of Use** | ✅ Point and click | ❌ Command line/setup required |
| **Documentation** | ✅ Built-in, always current | ❌ Separate documentation needed |
| **Authentication** | ✅ One-time setup | ❌ Manual header management |
| **Response Validation** | ✅ Schema validation | ❌ Manual verification |
| **Team Sharing** | ✅ Just share the URL | ❌ Share commands/collections |

### Tips for Using Swagger Effectively

1. **Start with GET endpoints** - they're safe to test and help you understand the data structure
2. **Use the "Authorize" button** - authenticate once, test all protected endpoints
3. **Check the "Model" tabs** - understand the exact JSON structure before making requests
4. **Try different response codes** - test both success and error scenarios
5. **Use real data** - create actual products/orders to test the full workflow

## ActiveAdmin Interface

The application includes a powerful ActiveAdmin interface for managing your e-commerce data. This provides a professional admin panel for managing products, users, orders, and more.

### Accessing the Admin Interface

1. **Start the Rails server** (if not already running):
   ```bash
   rails server
   ```

2. **Visit the admin panel**:
   ```
   http://localhost:3000/admin
   ```

3. **Login with default admin credentials**:
   - **Email**: `admin@example.com`
   - **Password**: `password`

### Admin Features

#### 🛍️ **Product Management**
- **View all products** with advanced filtering and search
- **Create new products** with full details (name, description, price, category, SKU)
- **Edit existing products** including inventory and pricing
- **Bulk operations** - activate/deactivate multiple products at once
- **Category filtering** - filter by Electronics, Home & Garden, Sports & Fitness, etc.
- **Stock management** - track inventory levels and availability
- **Status indicators** - visual badges for active/inactive and in-stock/out-of-stock

#### 👥 **User Management**
- **View all users** with registration details and activity
- **Manage admin privileges** - promote users to admin status
- **API token management** - view and revoke user API tokens
- **User order history** - see all orders for each customer
- **Authentication tracking** - monitor sign-in activity and IP addresses
- **User filtering** - search by email, name, admin status

#### 📦 **Order Management**
- **View all orders** with comprehensive order details
- **Order status tracking** - manage the fulfillment workflow:
  - 🟡 **Pending** - newly created orders
  - 🔵 **Processing** - orders being prepared
  - 🟢 **Shipped** - orders in transit
  - ✅ **Delivered** - completed orders
  - 🔴 **Cancelled** - cancelled orders
- **Bulk status updates** - process multiple orders simultaneously
- **Order details** - view line items, totals, and customer information
- **Advanced filtering** - filter by status, customer, date range, amount
- **Customer linking** - click through to customer details

#### 📊 **Dashboard & Analytics**
- **Overview dashboard** with key metrics and recent activity
- **Quick navigation** to all admin sections
- **Recent activity** tracking for audit purposes

### Admin Interface Navigation

#### Main Menu Items:
- **Dashboard** - Overview and quick stats
- **Products** - Product catalog management
- **Users** - Customer and admin user management
- **Orders** - Order processing and fulfillment
- **Admin Users** - Admin account management

#### Key Features:
- **Search and Filters** - Every section has powerful filtering capabilities
- **Batch Actions** - Perform operations on multiple items at once
- **Export Functions** - Download data for reporting (CSV format)
- **Responsive Design** - Works on desktop, tablet, and mobile devices

### Common Admin Tasks

#### Adding New Products:
1. Go to **Products** → **New Product**
2. Fill in product details:
   - Name and description
   - Category (from predefined list)
   - SKU (unique identifier)
   - Price and stock quantity
   - Active status
3. Click **Create Product**

#### Processing Orders:
1. Go to **Orders** to view all orders
2. Click on an order to view details
3. Update the status as orders progress:
   - Mark as **Processing** when preparing
   - Mark as **Shipped** when dispatched
   - Mark as **Delivered** when completed
4. Use batch actions to update multiple orders

#### Managing Users:
1. Go to **Users** to view all customers
2. Click on a user to see their profile and order history
3. Promote users to admin if needed
4. Revoke API tokens if necessary

#### Bulk Operations:
1. Select multiple items using checkboxes
2. Choose a batch action from the dropdown
3. Confirm the operation
4. Items will be updated in bulk

### Admin Security

- **Separate authentication** - Admin users are separate from regular users
- **Role-based access** - Only admin users can access the admin interface
- **Audit trail** - All admin actions are logged with timestamps
- **Session management** - Secure admin sessions with timeout

### Customizing the Admin Interface

The admin interface is highly customizable. Admin resource files are located in:
```
app/admin/
├── dashboard.rb          # Dashboard configuration
├── products.rb          # Product management
├── users.rb            # User management
├── orders.rb           # Order management
└── admin_users.rb      # Admin user management
```

### Creating Additional Admin Users

To create more admin users, you can:

1. **Via Rails console**:
   ```ruby
   rails console
   AdminUser.create!(email: 'newadmin@example.com', password: 'securepassword')
   ```

2. **Via the admin interface**:
   - Login as an existing admin
   - Go to **Admin Users** → **New Admin User**
   - Fill in email and password
   - Click **Create Admin User**

### Troubleshooting

#### Can't access admin interface:
- Ensure the server is running on `http://localhost:3000`
- Check that you're using the correct URL: `/admin`
- Verify admin user exists: `rails console` → `AdminUser.count`

#### Forgot admin password:
```ruby
rails console
admin = AdminUser.find_by(email: 'admin@example.com')
admin.update!(password: 'newpassword')
```

#### Admin interface styling issues:
- Ensure `dartsass-rails` gem is installed
- Restart the server after gem installation
- Check browser console for JavaScript errors

## Development

### Running Tests

```bash
rails test
```

### Code Style

This project follows Ruby and Rails best practices. Run RuboCop for style checking:

```bash
bundle exec rubocop
```

### Database

The application uses MongoDB with Mongoid. No migrations are needed, but you can seed the database:

```bash
rails db:seed
```

## Deployment

The application is configured for deployment with Kamal. See the deployment configuration in `.kamal/` directory.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is available as open source under the terms of the MIT License.
