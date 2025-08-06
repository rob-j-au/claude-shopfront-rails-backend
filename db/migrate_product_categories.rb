# Migration script to update existing products to use Category model
# This script maps existing string category values to Category records

puts "Starting product category migration..."

# Get all products that have a category string value
products_with_categories = Product.where(:category.exists => true, :category.ne => nil, :category.ne => "")

puts "Found #{products_with_categories.count} products with category strings to migrate"

migrated_count = 0
failed_count = 0

products_with_categories.each do |product|
  begin
    # Find the matching category by name
    category = Category.where(name: product[:category]).first
    
    if category
      # Update the product to use the category association
      product.category = category
      product.unset(:category) # Remove the old string field
      
      if product.save
        puts "✓ Migrated product '#{product.name}' to category '#{category.name}'"
        migrated_count += 1
      else
        puts "✗ Failed to save product '#{product.name}': #{product.errors.full_messages.join(', ')}"
        failed_count += 1
      end
    else
      puts "⚠ No matching category found for product '#{product.name}' with category '#{product[:category]}'"
      failed_count += 1
    end
  rescue => e
    puts "✗ Error migrating product '#{product.name}': #{e.message}"
    failed_count += 1
  end
end

puts "\nMigration completed!"
puts "Successfully migrated: #{migrated_count} products"
puts "Failed migrations: #{failed_count} products"
puts "Total products now with categories: #{Product.where(:category_id.exists => true).count}"
