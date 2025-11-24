# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
# ============================================
# 运行: rails db:seed
# ============================================

puts "Seeding database..."

# ============================================
# 1. 创建管理员账户 (Feature 1.1)
# ============================================
AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end
puts "✓ Admin user created: admin@example.com / password"

# ============================================
# 2. 创建所有省份和税率 (Feature 3.2.3)
# ============================================
provinces_data = [
  # 西部省份
  { name: 'British Columbia', code: 'BC', gst_rate: 5, pst_rate: 7, hst_rate: 0 },
  { name: 'Alberta', code: 'AB', gst_rate: 5, pst_rate: 0, hst_rate: 0 },
  { name: 'Saskatchewan', code: 'SK', gst_rate: 5, pst_rate: 6, hst_rate: 0 },
  { name: 'Manitoba', code: 'MB', gst_rate: 5, pst_rate: 7, hst_rate: 0 },

  # 中部省份 (HST)
  { name: 'Ontario', code: 'ON', gst_rate: 0, pst_rate: 0, hst_rate: 13 },

  # 东部省份 (HST)
  { name: 'Quebec', code: 'QC', gst_rate: 5, pst_rate: 9.975, hst_rate: 0 },
  { name: 'New Brunswick', code: 'NB', gst_rate: 0, pst_rate: 0, hst_rate: 15 },
  { name: 'Nova Scotia', code: 'NS', gst_rate: 0, pst_rate: 0, hst_rate: 15 },
  { name: 'Prince Edward Island', code: 'PE', gst_rate: 0, pst_rate: 0, hst_rate: 15 },
  { name: 'Newfoundland and Labrador', code: 'NL', gst_rate: 0, pst_rate: 0, hst_rate: 15 },

  # 北部领地
  { name: 'Yukon', code: 'YT', gst_rate: 5, pst_rate: 0, hst_rate: 0 },
  { name: 'Northwest Territories', code: 'NT', gst_rate: 5, pst_rate: 0, hst_rate: 0 },
  { name: 'Nunavut', code: 'NU', gst_rate: 5, pst_rate: 0, hst_rate: 0 }
]

provinces_data.each do |prov|
  Province.find_or_create_by!(code: prov[:code]) do |p|
    p.name = prov[:name]
    p.gst_rate = prov[:gst_rate]
    p.pst_rate = prov[:pst_rate]
    p.hst_rate = prov[:hst_rate]
  end
end
puts "✓ #{Province.count} provinces created with tax rates"

# ============================================
# 3. 创建分类 (Feature 1.5)
# ============================================
categories_data = [
  { name: 'Organic Produce', description: 'Fresh organic fruits and vegetables' },
  { name: 'Natural Supplements', description: 'Vitamins, minerals, and herbal supplements' },
  { name: 'Gluten-Free Products', description: 'Certified gluten-free foods and snacks' },
  { name: 'Eco-Friendly Household', description: 'Environmentally friendly cleaning and household products' },
  { name: 'Health Beverages', description: 'Organic teas, coffees, and health drinks' },
  { name: 'Organic Snacks', description: 'Healthy organic snack options' }
]

categories_data.each do |cat|
  Category.find_or_create_by!(name: cat[:name]) do |c|
    c.description = cat[:description]
  end
end
puts "✓ #{Category.count} categories created"

# ============================================
# 4. 创建产品 (Feature 1.2, 1.6)
# ============================================
# 获取分类
produce = Category.find_by(name: 'Organic Produce')
supplements = Category.find_by(name: 'Natural Supplements')
gluten_free = Category.find_by(name: 'Gluten-Free Products')
eco_friendly = Category.find_by(name: 'Eco-Friendly Household')
beverages = Category.find_by(name: 'Health Beverages')
snacks = Category.find_by(name: 'Organic Snacks')

products_data = [
  # Organic Produce
  { name: 'Organic Bananas Bundle', description: 'Fresh organic bananas from Ecuador, rich in potassium and naturally sweet. Perfect for smoothies, baking, or a healthy snack.', price: 4.99, stock: 100, categories: [ produce ], on_sale: true },
  { name: 'Organic Baby Spinach', description: 'Tender organic baby spinach leaves, pre-washed and ready to eat. Great for salads, smoothies, or sautéing.', price: 5.49, stock: 75, categories: [ produce ] },
  { name: 'Organic Avocados (3 pack)', description: 'Creamy Hass avocados grown organically. Rich in healthy fats and perfect for guacamole or toast.', price: 7.99, stock: 50, categories: [ produce ], on_sale: true },
  { name: 'Organic Blueberries', description: 'Sweet and tangy organic blueberries packed with antioxidants. Fresh from local farms.', price: 6.99, stock: 60, categories: [ produce ], is_new: true },
  { name: 'Organic Kale Bunch', description: 'Nutrient-dense organic kale, perfect for salads, chips, or adding to smoothies for extra nutrition.', price: 3.99, stock: 80, categories: [ produce ] },

  # Natural Supplements
  { name: 'Vitamin D3 2000 IU', description: 'High-potency Vitamin D3 supplements to support bone health and immune function. 120 softgels per bottle.', price: 18.99, stock: 150, categories: [ supplements ] },
  { name: 'Organic Turmeric Capsules', description: 'Powerful anti-inflammatory turmeric with black pepper for enhanced absorption. 90 capsules.', price: 24.99, stock: 100, categories: [ supplements ], is_new: true },
  { name: 'Omega-3 Fish Oil', description: 'Pure wild-caught fish oil providing essential EPA and DHA fatty acids for heart and brain health.', price: 29.99, stock: 80, categories: [ supplements ] },
  { name: 'Probiotic 50 Billion CFU', description: 'Multi-strain probiotic supplement for digestive health and immune support. 30 capsules.', price: 34.99, stock: 60, categories: [ supplements ], on_sale: true },
  { name: 'Magnesium Glycinate', description: 'Highly absorbable magnesium for muscle relaxation, sleep support, and stress relief. 120 capsules.', price: 22.99, stock: 90, categories: [ supplements ] },

  # Gluten-Free Products
  { name: 'Gluten-Free Flour Blend', description: 'All-purpose gluten-free flour perfect for baking bread, cakes, and pastries. 1kg bag.', price: 8.99, stock: 120, categories: [ gluten_free ] },
  { name: 'GF Pasta Variety Pack', description: 'Assorted gluten-free pasta shapes made from rice and quinoa. Includes penne, fusilli, and spaghetti.', price: 12.99, stock: 70, categories: [ gluten_free ], is_new: true },
  { name: 'Gluten-Free Oats', description: 'Certified gluten-free rolled oats, perfect for oatmeal, granola, or baking. 500g.', price: 6.99, stock: 100, categories: [ gluten_free ] },
  { name: 'GF Crackers Multi-Seed', description: 'Crunchy multi-seed crackers made without gluten. Great with cheese or dips.', price: 5.49, stock: 85, categories: [ gluten_free, snacks ] },
  { name: 'Gluten-Free Bread Loaf', description: 'Soft and delicious gluten-free sandwich bread. No artificial preservatives.', price: 7.99, stock: 40, categories: [ gluten_free ], on_sale: true },

  # Eco-Friendly Household
  { name: 'Bamboo Paper Towels', description: 'Reusable bamboo paper towels that replace up to 60 rolls of traditional paper towels. Washable and eco-friendly.', price: 15.99, stock: 200, categories: [ eco_friendly ], is_new: true },
  { name: 'Plant-Based Dish Soap', description: 'Biodegradable dish soap made from plant-derived ingredients. Tough on grease, gentle on the planet.', price: 6.99, stock: 150, categories: [ eco_friendly ] },
  { name: 'Beeswax Food Wraps', description: 'Set of 3 reusable beeswax wraps to replace plastic wrap. Various sizes included.', price: 19.99, stock: 80, categories: [ eco_friendly ] },
  { name: 'Natural Laundry Detergent', description: 'Concentrated plant-based laundry detergent. Free from harsh chemicals. 64 loads.', price: 14.99, stock: 100, categories: [ eco_friendly ], on_sale: true },
  { name: 'Compostable Garbage Bags', description: 'Pack of 50 compostable garbage bags made from plant starch. Perfect for kitchen compost.', price: 12.99, stock: 120, categories: [ eco_friendly ] },

  # Health Beverages
  { name: 'Organic Green Tea Collection', description: 'Assortment of 6 organic green tea varieties including matcha, sencha, and jasmine. 48 tea bags.', price: 16.99, stock: 90, categories: [ beverages ] },
  { name: 'Cold-Pressed Juice Pack', description: 'Set of 6 cold-pressed organic juices. Includes green, citrus, and berry blends.', price: 29.99, stock: 45, categories: [ beverages ], is_new: true },
  { name: 'Organic Fair-Trade Coffee', description: 'Medium roast whole bean coffee from small organic farms. Rich and smooth flavor. 340g.', price: 14.99, stock: 110, categories: [ beverages ] },
  { name: 'Herbal Sleep Tea', description: 'Calming blend of chamomile, lavender, and valerian root to promote restful sleep. 20 bags.', price: 8.99, stock: 70, categories: [ beverages ] },
  { name: 'Organic Kombucha Variety', description: 'Pack of 4 organic kombucha drinks in assorted flavors. Naturally fermented with live cultures.', price: 15.99, stock: 55, categories: [ beverages ], on_sale: true },

  # Organic Snacks
  { name: 'Organic Trail Mix', description: 'Premium mix of organic nuts, seeds, and dried fruits. Perfect for hiking or office snacking. 400g.', price: 11.99, stock: 130, categories: [ snacks ] },
  { name: 'Dark Chocolate Almonds', description: 'Organic almonds covered in rich 70% dark chocolate. Antioxidant-rich indulgence. 200g.', price: 9.99, stock: 85, categories: [ snacks ], is_new: true },
  { name: 'Kale Chips Sea Salt', description: 'Crispy organic kale chips with just a touch of sea salt. Low calorie, high nutrition. 50g.', price: 5.99, stock: 100, categories: [ snacks ] },
  { name: 'Organic Energy Bars (6 pack)', description: 'Wholesome energy bars made with oats, nuts, and dried fruit. No added sugar.', price: 14.99, stock: 90, categories: [ snacks ] },
  { name: 'Coconut Chips Toasted', description: 'Lightly toasted organic coconut chips. Great for snacking or adding to recipes. 150g.', price: 4.99, stock: 110, categories: [ snacks ], on_sale: true }
]

products_data.each do |prod|
  product = Product.find_or_create_by!(name: prod[:name]) do |p|
    p.description = prod[:description]
    p.price = prod[:price]
    p.stock_quantity = prod[:stock]
    p.on_sale = prod[:on_sale] || false
    p.is_new = prod[:is_new] || false
  end

  # 添加分类关联
  prod[:categories].each do |category|
    ProductCategory.find_or_create_by!(product: product, category: category)
  end
end
puts "✓ #{Product.count} products created with category associations"

# ============================================
# 5. 创建页面 (Feature 1.4)
# ============================================
Page.find_or_create_by!(slug: 'about') do |p|
  p.title = 'About Us'
  p.content = <<~HTML
    <h2>Welcome to Northern Harvest Natural Foods</h2>
    <p>Northern Harvest has been serving the Winnipeg community with premium organic and natural foods since 2009. Our mission is to make healthy, sustainable living accessible to everyone.</p>
    <h3>Our Story</h3>
    <p>Founded by a group of health-conscious local entrepreneurs, Northern Harvest started as a small farmers market stall. Today, we operate two retail locations and this online store, serving thousands of families across Manitoba.</p>
    <h3>Our Values</h3>
    <ul>
      <li><strong>Quality:</strong> We carefully select only the finest organic products</li>
      <li><strong>Sustainability:</strong> We prioritize eco-friendly and locally sourced products</li>
      <li><strong>Community:</strong> We support local farmers and producers</li>
      <li><strong>Health:</strong> We believe in the power of natural, wholesome foods</li>
    </ul>
  HTML
end

Page.find_or_create_by!(slug: 'contact') do |p|
  p.title = 'Contact Us'
  p.content = <<~HTML
    <h2>Get in Touch</h2>
    <p>We'd love to hear from you! Whether you have questions about our products, need help with an order, or just want to say hello, we're here to help.</p>
    <h3>Store Locations</h3>
    <p><strong>Downtown Location:</strong><br>
    123 Main Street, Winnipeg, MB R3C 1A5<br>
    Phone: (204) 555-0123</p>
    <p><strong>South Location:</strong><br>
    456 Pembina Highway, Winnipeg, MB R3T 2E8<br>
    Phone: (204) 555-0456</p>
    <h3>Hours of Operation</h3>
    <p>Monday - Friday: 9:00 AM - 8:00 PM<br>
    Saturday: 9:00 AM - 6:00 PM<br>
    Sunday: 10:00 AM - 5:00 PM</p>
    <h3>Email Us</h3>
    <p>General Inquiries: <a href="mailto:info@northernharvest.ca">info@northernharvest.ca</a><br>
    Customer Support: <a href="mailto:support@northernharvest.ca">support@northernharvest.ca</a></p>
  HTML
end
puts "✓ #{Page.count} pages created (About & Contact)"

# ============================================
# 完成
# ============================================
puts ""
puts "=" * 50
puts "Database seeding completed successfully!"
puts "=" * 50
puts ""
puts "Summary:"
puts "  - Admin Users: #{AdminUser.count}"
puts "  - Provinces: #{Province.count}"
puts "  - Categories: #{Category.count}"
puts "  - Products: #{Product.count}"
puts "  - Pages: #{Page.count}"
puts ""
puts "Admin Login: admin@example.com / password"
puts "=" * 50
