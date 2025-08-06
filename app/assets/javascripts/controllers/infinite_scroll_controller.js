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
    this.loading = false
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      threshold: 0.1,
      rootMargin: "100px"
    })
    
    if (this.hasLoadingTarget) {
      this.observer.observe(this.loadingTarget)
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
    const stockBadge = product.in_stock 
      ? `<span class="badge bg-success">In Stock (${product.stock_quantity})</span>`
      : `<span class="badge bg-danger">Out of Stock</span>`
    
    const addToCartButton = product.in_stock 
      ? `<form action="/cart/add" method="post" class="d-inline mt-2">
           <input type="hidden" name="product_id" value="${product.id}">
           <input type="hidden" name="quantity" value="1">
           <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
           <input type="submit" value="Add to Cart" class="btn btn-success btn-sm">
         </form>`
      : ''
    
    const truncatedDescription = product.description.length > 100 
      ? product.description.substring(0, 100) + '...'
      : product.description
    
    return `
      <div class="col-md-4 mb-4">
        <div class="card h-100">
          <div class="card-body">
            <h5 class="card-title">${this.escapeHtml(product.name)}</h5>
            <p class="card-text">${this.escapeHtml(truncatedDescription)}</p>
            <p class="card-text">
              <strong>${this.escapeHtml(product.price)}</strong>
              ${stockBadge}
            </p>
            <p class="card-text">
              <small class="text-muted">SKU: ${this.escapeHtml(product.sku)}</small>
            </p>
          </div>
          <div class="card-footer">
            <a href="${product.show_path}" class="btn btn-outline-primary btn-sm">View</a>
            <a href="${product.edit_path}" class="btn btn-outline-secondary btn-sm">Edit</a>
            <a href="${product.delete_path}" data-method="delete" data-confirm="Are you sure?" class="btn btn-outline-danger btn-sm">Delete</a>
            ${addToCartButton}
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
