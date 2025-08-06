import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="infinite-scroll"
export default class extends Controller {
  static targets = ["container", "loading", "endMessage"]
  static values = { 
    url: String,
    page: Number,
    hasNextPage: Boolean,
    totalPages: Number
  }

  connect() {
    console.log('Infinite scroll controller connected!')
    console.log('Values:', {
      url: this.urlValue,
      page: this.pageValue,
      hasNextPage: this.hasNextPageValue,
      totalPages: this.totalPagesValue
    })
    
    this.loading = false
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      threshold: 0.1,
      rootMargin: "100px"
    })
    
    if (this.hasLoadingTarget) {
      console.log('Setting up intersection observer on loading target')
      this.observer.observe(this.loadingTarget)
    } else {
      console.log('No loading target found')
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasNextPageValue && !this.loading) {
        this.loadMore()
      }
    })
  }

  async loadMore() {
    if (this.loading || !this.hasNextPageValue) return
    
    this.loading = true
    this.showLoading()
    
    try {
      const nextPage = this.pageValue + 1
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set('page', nextPage)
      
      // Preserve existing search and category filters
      const currentParams = new URLSearchParams(window.location.search)
      if (currentParams.get('search')) {
        url.searchParams.set('search', currentParams.get('search'))
      }
      if (currentParams.get('category')) {
        url.searchParams.set('category', currentParams.get('category'))
      }
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const data = await response.json()
      
      // Update pagination values
      this.pageValue = data.pagination.current_page
      this.hasNextPageValue = data.pagination.has_next_page
      this.totalPagesValue = data.pagination.total_pages
      
      // Append new products to container
      this.appendProducts(data.products)
      
      // Hide loading indicator
      this.hideLoading()
      
      // Show end message if no more pages
      if (!this.hasNextPageValue) {
        this.showEndMessage()
      }
      
    } catch (error) {
      console.error('Error loading more products:', error)
      this.hideLoading()
      this.showError()
    }
    
    this.loading = false
  }

  appendProducts(products) {
    products.forEach(product => {
      const productHtml = this.createProductCard(product)
      this.containerTarget.insertAdjacentHTML('beforeend', productHtml)
    })
  }

  createProductCard(product) {
    const categoryBadge = product.category 
      ? `<span class="badge bg-secondary">${this.escapeHtml(product.category.name)}</span>`
      : ''
    
    const stockBadge = product.in_stock 
      ? `<span class="badge bg-success">
           <i class="bi bi-check-circle me-1"></i>
           ${product.stock_quantity} in stock
         </span>`
      : `<span class="badge bg-danger">
           <i class="bi bi-x-circle me-1"></i>
           Out of Stock
         </span>`
    
    const truncatedDescription = product.description && product.description.length > 100 
      ? product.description.substring(0, 100) + '...'
      : (product.description || 'No description available')
    
    const imageUrl = `https://picsum.photos/seed/${Math.abs(product.id.toString().split('').reduce((a, b) => { a = ((a << 5) - a) + b.charCodeAt(0); return a & a }, 0)) % 1000}/400/250`
    
    return `
      <div class="col-lg-4 col-md-6 mb-4">
        <div class="card h-100 shadow-sm">
          <!-- Product Image -->
          <img src="${imageUrl}" alt="${this.escapeHtml(product.name)}" class="card-img-top" style="height: 200px; object-fit: cover;">
          
          <div class="card-body d-flex flex-column">
            <!-- Product Header -->
            <div class="d-flex justify-content-between align-items-start mb-3">
              <h5 class="card-title mb-0">${this.escapeHtml(product.name)}</h5>
              ${categoryBadge}
            </div>
            
            <!-- Price -->
            <div class="h5 text-primary mb-3 fw-bold">${this.escapeHtml(product.formatted_price || product.price)}</div>
            
            <!-- Description -->
            <p class="card-text text-muted mb-3">${this.escapeHtml(truncatedDescription)}</p>
            
            <!-- Stock Status -->
            <div class="mb-3">
              ${stockBadge}
            </div>
            
            <!-- SKU -->
            <div class="text-muted small mb-3">
              <i class="bi bi-upc me-1"></i>
              SKU: ${this.escapeHtml(product.sku)}
            </div>
            
            <!-- Action Buttons -->
            <div class="mt-auto">
              <div class="d-grid gap-2">
                <a href="/products/${product.id}" class="btn btn-primary">
                  <i class="bi bi-eye me-2"></i>
                  View Details
                </a>
                <a href="/products/${product.id}/edit" class="btn btn-outline-secondary">
                  <i class="bi bi-pencil me-2"></i>
                  Edit Product
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    `
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = 'block'
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = 'none'
    }
  }

  showEndMessage() {
    if (this.hasEndMessageTarget) {
      this.endMessageTarget.style.display = 'block'
    }
  }

  showError() {
    // You could implement a more sophisticated error display here
    const errorHtml = `
      <div class="col-12">
        <div class="alert alert-danger" role="alert">
          <h6>Error loading more products</h6>
          <p class="mb-0">Please try refreshing the page.</p>
        </div>
      </div>
    `
    this.containerTarget.insertAdjacentHTML('beforeend', errorHtml)
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
