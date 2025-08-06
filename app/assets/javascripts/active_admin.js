// ActiveAdmin JavaScript for Propshaft compatibility
// This file provides the basic functionality that ActiveAdmin expects

// Basic ActiveAdmin functionality
document.addEventListener('DOMContentLoaded', function() {
  console.log('ActiveAdmin loaded successfully');
  
  // Basic form enhancements
  const forms = document.querySelectorAll('form');
  forms.forEach(function(form) {
    // Add basic form validation feedback
    form.addEventListener('submit', function(e) {
      const requiredFields = form.querySelectorAll('[required]');
      let hasErrors = false;
      
      requiredFields.forEach(function(field) {
        if (!field.value.trim()) {
          field.style.borderColor = '#d9534f';
          hasErrors = true;
        } else {
          field.style.borderColor = '#ccc';
        }
      });
      
      if (hasErrors) {
        e.preventDefault();
        alert('Please fill in all required fields.');
      }
    });
  });
  
  // Basic table row highlighting
  const tableRows = document.querySelectorAll('table tbody tr');
  tableRows.forEach(function(row) {
    row.addEventListener('mouseenter', function() {
      this.style.backgroundColor = '#f0f0f0';
    });
    
    row.addEventListener('mouseleave', function() {
      this.style.backgroundColor = '';
    });
  });
});
