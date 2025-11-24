require "csv"

puts "Seeding database..."

AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end
puts "✓ Admin user created"


# Import provinces_data.csv
provinces_filepath = Rails.root.join("db", "provinces_data.csv")

CSV.foreach(provinces_filepath, headers: true) do |row|
  Province.find_or_create_by!(code: row["code"]) do |p|
    p.name     = row["name"]
    p.gst_rate = row["gst_rate"]
    p.pst_rate = row["pst_rate"]
    p.hst_rate = row["hst_rate"]
  end
end

puts "✓ #{Province.count} provinces imported"


# Import categories_data.csv
categories_filepath = Rails.root.join("db", "categories_data.csv")

CSV.foreach(categories_filepath, headers: true) do |row|
  Category.find_or_create_by!(name: row["name"]) do |c|
    c.description = row["description"]
  end
end

puts "✓ #{Category.count} categories imported"


# products_data.csv
products_filepath = Rails.root.join("db", "products_data.csv")

CSV.foreach(products_filepath, headers: true) do |row|
  product = Product.find_or_create_by!(name: row["name"]) do |p|
    p.description     = row["description"]
    p.price           = row["price"]
    p.stock_quantity  = row["stock"]
    p.on_sale         = row["on_sale"] == "true"
    p.is_new          = row["is_new"] == "true"
  end

  # 处理多个分类： "Organic Produce|Organic Snacks"
  categories = row["categories"].to_s.split("|").map(&:strip)

  categories.each do |cat_name|
    category = Category.find_by(name: cat_name)
    if category
      ProductCategory.find_or_create_by!(product: product, category: category)
    else
      puts "⚠ Warning: Category '#{cat_name}' not found for product #{product.name}"
    end
  end
end

puts "✓ #{Product.count} products imported with category associations"


Page.find_or_create_by!(slug: 'about') do |p|
  p.title = 'About Us'
  p.content = "<section id=\"about\">
  <h2>Welcome to Northern Harvest Natural Foods</h2>
  <p>
    Northern Harvest Natural Foods has been proudly serving the Winnipeg community
    with premium organic and natural foods since 2009. Our mission is to make
    healthy, sustainable living accessible to everyone, while supporting local
    farmers and producers.
  </p>

  <h3>Our Story</h3>
  <p>
    Founded by a group of health-conscious local entrepreneurs, Northern Harvest
    began as a small farmers market stall. Over the years, we have grown into a
    trusted brand with multiple retail locations and an online store, serving
    thousands of families across Manitoba.
  </p>

  <h3>Our Values</h3>
  <ul>
    <li><strong>Quality:</strong> We carefully select only the finest organic and natural products.</li>
    <li><strong>Sustainability:</strong> We prioritize eco-friendly packaging and locally sourced goods.</li>
    <li><strong>Community:</strong> We actively support local farmers, producers, and community initiatives.</li>
    <li><strong>Health:</strong> We believe in the power of wholesome, nutrient-rich foods to nourish the body and mind.</li>
    <li><strong>Education:</strong> We aim to inform and inspire our customers about healthy living choices.</li>
  </ul>

  <h3>Why Choose Us?</h3>
  <p>
    At Northern Harvest, we are committed to creating a shopping experience that is
    friendly, educational, and sustainable. Our knowledgeable staff are always
    ready to help you find the best products for your lifestyle.
  </p>
</section>
"
end

Page.find_or_create_by!(slug: 'contact') do |p|
  p.title = 'Contact Us'
  p.content = "<section id=\"contact\">
  <h2>Get in Touch</h2>
  <p>
    Thank you for visiting Northern Harvest Natural Foods!
    Whether you have questions about our natural products, need help with an order,
    or simply want to connect with our team, we're here to help.
  </p>

  <h3>Store Locations</h3>

  <p>
    <strong>Downtown Winnipeg Store:</strong><br>
    218 Willow Creek Lane, Winnipeg, MB R3B 2Y7<br>
    Phone: (204) 555‑1324<br>
    Email: <a href=\"mailto:downtown@northernharvest.ca\">downtown@northernharvest.ca</a>
  </p>

  <p>
    <strong>South Winnipeg Store:</strong><br>
    742 Maple Ridge Drive, Winnipeg, MB R3T 5K3<br>
    Phone: (204) 555‑4981<br>
    Email: <a href=\"mailto:south@northernharvest.ca\">south@northernharvest.ca</a>
  </p>

  <p>
    <strong>West Winnipeg Store:</strong><br>
    91 Meadow Brook Trail, Winnipeg, MB R3Y 0A9<br>
    Phone: (204) 555‑2840<br>
    Email: <a href=\"mailto:west@northernharvest.ca\">west@northernharvest.ca</a>
  </p>

  <h3>Hours of Operation</h3>
  <p>
    Monday – Friday: 9:00 AM – 8:00 PM<br>
    Saturday: 9:00 AM – 6:00 PM<br>
    Sunday: 10:00 AM – 5:00 PM
  </p>

  <h3>Email Us</h3>
  <p>
    General Inquiries: <a href=\"mailto:info@northernharvest.ca\">info@northernharvest.ca</a><br>
    Customer Support: <a href=\"mailto:support@northernharvest.ca\">support@northernharvest.ca</a><br>
    Wholesale / Partners: <a href=\"mailto:partners@northernharvest.ca\">partners@northernharvest.ca</a>
  </p>
</section>
"
end

puts "✓ #{Page.count} pages created"

all_categories = Category.all

100.times do
  name = Faker::Commerce.product_name + " #{Faker::Number.number(digits: 3)}"

  product = Product.create!(
    name: name,
    description: Faker::Food.description,
    price: Faker::Commerce.price(range: 3.0..50.0),
    stock_quantity: Faker::Number.between(from: 10, to: 200),
    on_sale: Faker::Boolean.boolean(true_ratio: 0.2),
    is_new: Faker::Boolean.boolean(true_ratio: 0.3)
  )

  product_categories = all_categories.sample(rand(1..2))
  product_categories.each do |cat|
    ProductCategory.create!(product: product, category: cat)
  end
end

puts "✓ 100 fake products created!"

puts ""
puts "=" * 50
puts "Database seeding completed!"
puts "=" * 50
