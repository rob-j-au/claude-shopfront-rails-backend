# Create initial categories
categories = [
  { name: 'Electronics', description: 'Electronic devices, gadgets, and accessories' },
  { name: 'Home & Garden', description: 'Home improvement, furniture, and garden supplies' },
  { name: 'Sports & Fitness', description: 'Sports equipment, fitness gear, and outdoor activities' },
  { name: 'Books & Media', description: 'Books, magazines, movies, and digital media' },
  { name: 'Fashion & Accessories', description: 'Clothing, shoes, jewelry, and fashion accessories' },
  { name: 'Kitchen & Dining', description: 'Kitchen appliances, cookware, and dining accessories' },
  { name: 'Office Supplies', description: 'Office equipment, stationery, and business supplies' },
  { name: 'Beauty & Personal Care', description: 'Cosmetics, skincare, and personal hygiene products' },
  { name: 'Automotive & Tools', description: 'Car accessories, tools, and automotive supplies' },
  { name: 'Pet Supplies', description: 'Pet food, toys, and accessories for animals' },
  { name: 'Gaming & Entertainment', description: 'Video games, board games, and entertainment products' },
  { name: 'Travel & Outdoor', description: 'Travel gear, camping equipment, and outdoor supplies' },
  { name: 'Health & Wellness', description: 'Health supplements, medical supplies, and wellness products' },
  { name: 'Baby & Kids', description: 'Baby products, toys, and children\'s items' },
  { name: 'Accessories', description: 'General accessories and miscellaneous items' }
]

puts "Creating categories..."

categories.each do |category_data|
  category = Category.find_or_create_by(name: category_data[:name]) do |c|
    c.description = category_data[:description]
    c.active = true
  end
  
  if category.persisted?
    puts "✓ Created/found category: #{category.name}"
  else
    puts "✗ Failed to create category: #{category_data[:name]} - #{category.errors.full_messages.join(', ')}"
  end
end

puts "Categories creation completed!"
puts "Total categories: #{Category.count}"
