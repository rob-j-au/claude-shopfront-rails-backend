# Load or create categories first
puts "Loading categories..."
load Rails.root.join('db', 'seeds_categories.rb')

# Create sample products
products = [
  # Electronics
  {
    name: "Wireless Bluetooth Headphones",
    description: "High-quality wireless headphones with noise cancellation and 30-hour battery life. Perfect for music lovers and professionals.",
    price: 199.99,
    stock_quantity: 25,
    sku: "WBH-001",
    category: "Electronics",
    active: true
  },
  {
    name: "Smart Fitness Watch",
    description: "Track your fitness goals with this advanced smartwatch featuring heart rate monitoring, GPS, and sleep tracking.",
    price: 299.99,
    stock_quantity: 15,
    sku: "SFW-002",
    category: "Electronics",
    active: true
  },
  {
    name: "Portable Laptop Stand",
    description: "Ergonomic aluminum laptop stand that's lightweight and adjustable. Perfect for remote work and travel.",
    price: 49.99,
    stock_quantity: 50,
    sku: "PLS-003",
    category: "Accessories",
    active: true
  },
  {
    name: "Wireless Charging Pad",
    description: "Fast wireless charging pad compatible with all Qi-enabled devices. Sleek design with LED indicator.",
    price: 29.99,
    stock_quantity: 100,
    sku: "WCP-004",
    category: "Electronics",
    active: true
  },
  {
    name: "USB-C Hub",
    description: "7-in-1 USB-C hub with HDMI, USB 3.0 ports, SD card reader, and power delivery. Essential for modern laptops.",
    price: 79.99,
    stock_quantity: 30,
    sku: "UCH-005",
    category: "Accessories",
    active: true
  },
  {
    name: "Mechanical Keyboard",
    description: "Premium mechanical keyboard with RGB backlighting and tactile switches. Perfect for gaming and typing.",
    price: 149.99,
    stock_quantity: 20,
    sku: "MKB-006",
    category: "Electronics",
    active: true
  },
  # Home & Garden
  {
    name: "Smart LED Light Bulbs (4-Pack)",
    description: "WiFi-enabled smart bulbs with 16 million colors and voice control compatibility. Energy-efficient and long-lasting.",
    price: 39.99,
    stock_quantity: 75,
    sku: "SLB-007",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Ceramic Plant Pot Set",
    description: "Beautiful set of 3 ceramic plant pots with drainage holes and saucers. Perfect for indoor plants and herbs.",
    price: 24.99,
    stock_quantity: 60,
    sku: "CPP-008",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Essential Oil Diffuser",
    description: "Ultrasonic aromatherapy diffuser with 7 LED colors and timer settings. Creates a relaxing atmosphere.",
    price: 34.99,
    stock_quantity: 45,
    sku: "EOD-009",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Bamboo Cutting Board Set",
    description: "Eco-friendly bamboo cutting board set with 3 different sizes. Antimicrobial and knife-friendly surface.",
    price: 29.99,
    stock_quantity: 80,
    sku: "BCS-010",
    category: "Home & Garden",
    active: true
  },
  # Sports & Fitness
  {
    name: "Yoga Mat with Carrying Strap",
    description: "Non-slip yoga mat made from eco-friendly TPE material. 6mm thick for comfort and stability.",
    price: 19.99,
    stock_quantity: 120,
    sku: "YMC-011",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Resistance Bands Set",
    description: "Complete resistance bands set with 5 different resistance levels, door anchor, and workout guide.",
    price: 24.99,
    stock_quantity: 90,
    sku: "RBS-012",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Water Bottle with Time Markers",
    description: "32oz motivational water bottle with hourly time markers. BPA-free and leak-proof design.",
    price: 14.99,
    stock_quantity: 150,
    sku: "WBT-013",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Foam Roller for Muscle Recovery",
    description: "High-density foam roller for deep tissue massage and muscle recovery. Perfect for athletes and fitness enthusiasts.",
    price: 22.99,
    stock_quantity: 65,
    sku: "FRM-014",
    category: "Sports & Fitness",
    active: true
  },
  # Books & Media
  {
    name: "The Art of Clean Code",
    description: "Essential guide to writing maintainable and efficient code. Perfect for developers of all levels.",
    price: 34.99,
    stock_quantity: 40,
    sku: "ACC-015",
    category: "Books & Media",
    active: true
  },
  {
    name: "Mindfulness Journal",
    description: "Daily mindfulness journal with guided prompts and reflection exercises. Premium paper and binding.",
    price: 18.99,
    stock_quantity: 85,
    sku: "MJR-016",
    category: "Books & Media",
    active: true
  },
  {
    name: "Bluetooth Audiobook Speaker",
    description: "Compact Bluetooth speaker optimized for audiobooks and podcasts. 12-hour battery life.",
    price: 45.99,
    stock_quantity: 35,
    sku: "BAS-017",
    category: "Books & Media",
    active: true
  },
  # Fashion & Accessories
  {
    name: "Leather Crossbody Bag",
    description: "Genuine leather crossbody bag with adjustable strap and multiple compartments. Perfect for daily use.",
    price: 89.99,
    stock_quantity: 25,
    sku: "LCB-018",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Polarized Sunglasses",
    description: "UV400 protection polarized sunglasses with lightweight titanium frame. Includes carrying case.",
    price: 59.99,
    stock_quantity: 70,
    sku: "PSG-019",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Silk Scarf Collection",
    description: "Luxurious silk scarf with hand-painted design. Versatile accessory for any outfit.",
    price: 42.99,
    stock_quantity: 30,
    sku: "SSC-020",
    category: "Fashion & Accessories",
    active: true
  },
  # Kitchen & Dining
  {
    name: "Stainless Steel Coffee Grinder",
    description: "Electric coffee grinder with adjustable coarseness settings. Perfect for fresh coffee every morning.",
    price: 67.99,
    stock_quantity: 40,
    sku: "SCG-021",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Non-Stick Cookware Set",
    description: "8-piece non-stick cookware set with ceramic coating. Dishwasher safe and PFOA-free.",
    price: 129.99,
    stock_quantity: 20,
    sku: "NCS-022",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Glass Food Storage Containers",
    description: "Set of 10 glass food storage containers with airtight lids. Microwave and dishwasher safe.",
    price: 39.99,
    stock_quantity: 55,
    sku: "GFS-023",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Electric Kettle with Temperature Control",
    description: "1.7L electric kettle with precise temperature control for different tea types. Auto shut-off feature.",
    price: 54.99,
    stock_quantity: 35,
    sku: "EKT-024",
    category: "Kitchen & Dining",
    active: true
  },
  # Office Supplies
  {
    name: "Ergonomic Office Chair",
    description: "Adjustable ergonomic office chair with lumbar support and breathable mesh back. Perfect for long work sessions.",
    price: 189.99,
    stock_quantity: 15,
    sku: "EOC-025",
    category: "Office Supplies",
    active: true
  },
  {
    name: "Wireless Mouse and Keyboard Combo",
    description: "Slim wireless keyboard and mouse combo with long battery life. Quiet keys and precise tracking.",
    price: 49.99,
    stock_quantity: 60,
    sku: "WMK-026",
    category: "Office Supplies",
    active: true
  },
  {
    name: "Desktop Organizer with Wireless Charging",
    description: "Bamboo desktop organizer with built-in wireless charging pad and multiple compartments.",
    price: 44.99,
    stock_quantity: 45,
    sku: "DOW-027",
    category: "Office Supplies",
    active: true
  },
  {
    name: "LED Desk Lamp with USB Charging",
    description: "Adjustable LED desk lamp with multiple brightness levels and built-in USB charging port.",
    price: 32.99,
    stock_quantity: 75,
    sku: "LDL-028",
    category: "Office Supplies",
    active: true
  },
  # Beauty & Personal Care
  {
    name: "Skincare Gift Set",
    description: "Complete skincare routine gift set with cleanser, toner, serum, and moisturizer. Suitable for all skin types.",
    price: 79.99,
    stock_quantity: 30,
    sku: "SGS-029",
    category: "Beauty & Personal Care",
    active: true
  },
  {
    name: "Electric Toothbrush with Smart Timer",
    description: "Rechargeable electric toothbrush with 2-minute smart timer and 3 brushing modes. Includes travel case.",
    price: 89.99,
    stock_quantity: 40,
    sku: "ETB-030",
    category: "Beauty & Personal Care",
    active: true
  },
  # Automotive & Tools
  {
    name: "Wireless Car Charger Mount",
    description: "Fast wireless charging car mount with automatic clamping and 360-degree rotation. Compatible with all phones.",
    price: 34.99,
    stock_quantity: 85,
    sku: "WCM-031",
    category: "Automotive & Tools",
    active: true
  },
  {
    name: "Multi-Tool with LED Flashlight",
    description: "Compact 15-in-1 multi-tool with pliers, screwdrivers, knife, and built-in LED flashlight. Perfect for emergencies.",
    price: 28.99,
    stock_quantity: 120,
    sku: "MTL-032",
    category: "Automotive & Tools",
    active: true
  },
  {
    name: "Tire Pressure Gauge Digital",
    description: "Digital tire pressure gauge with LCD display and air release valve. Accurate readings for optimal tire performance.",
    price: 16.99,
    stock_quantity: 95,
    sku: "TPG-033",
    category: "Automotive & Tools",
    active: true
  },
  {
    name: "Cordless Drill Set",
    description: "20V cordless drill with 2 batteries, charger, and 50-piece accessory kit. Perfect for home improvement projects.",
    price: 89.99,
    stock_quantity: 25,
    sku: "CDS-034",
    category: "Automotive & Tools",
    active: true
  },
  # Pet Supplies
  {
    name: "Interactive Dog Puzzle Toy",
    description: "Mental stimulation puzzle toy for dogs with treat compartments. Helps reduce boredom and anxiety.",
    price: 22.99,
    stock_quantity: 75,
    sku: "IPT-035",
    category: "Pet Supplies",
    active: true
  },
  {
    name: "Self-Cleaning Cat Litter Box",
    description: "Automatic self-cleaning litter box with odor control and waste disposal system. Low maintenance solution.",
    price: 149.99,
    stock_quantity: 15,
    sku: "SCL-036",
    category: "Pet Supplies",
    active: true
  },
  {
    name: "Orthopedic Pet Bed",
    description: "Memory foam orthopedic pet bed with removable washable cover. Provides joint support for senior pets.",
    price: 45.99,
    stock_quantity: 60,
    sku: "OPB-037",
    category: "Pet Supplies",
    active: true
  },
  {
    name: "GPS Pet Tracker Collar",
    description: "Waterproof GPS tracker collar with real-time location tracking and activity monitoring. Peace of mind for pet owners.",
    price: 79.99,
    stock_quantity: 40,
    sku: "GPT-038",
    category: "Pet Supplies",
    active: true
  },
  # Gaming & Entertainment
  {
    name: "Gaming Headset with 7.1 Surround",
    description: "Professional gaming headset with 7.1 surround sound, noise-canceling microphone, and RGB lighting.",
    price: 89.99,
    stock_quantity: 55,
    sku: "GHS-039",
    category: "Gaming & Entertainment",
    active: true
  },
  {
    name: "Wireless Gaming Mouse",
    description: "High-precision wireless gaming mouse with 16,000 DPI, programmable buttons, and 70-hour battery life.",
    price: 69.99,
    stock_quantity: 70,
    sku: "WGM-040",
    category: "Gaming & Entertainment",
    active: true
  },
  {
    name: "Streaming Webcam 4K",
    description: "4K webcam with auto-focus, built-in microphone, and privacy shutter. Perfect for streaming and video calls.",
    price: 119.99,
    stock_quantity: 35,
    sku: "SWC-041",
    category: "Gaming & Entertainment",
    active: true
  },
  {
    name: "Portable Gaming Monitor",
    description: "15.6-inch portable gaming monitor with 144Hz refresh rate and USB-C connectivity. Perfect for mobile gaming.",
    price: 199.99,
    stock_quantity: 20,
    sku: "PGM-042",
    category: "Gaming & Entertainment",
    active: true
  },
  # Travel & Outdoor
  {
    name: "Travel Backpack with USB Port",
    description: "Anti-theft travel backpack with built-in USB charging port, laptop compartment, and water-resistant material.",
    price: 54.99,
    stock_quantity: 80,
    sku: "TBU-043",
    category: "Travel & Outdoor",
    active: true
  },
  {
    name: "Portable Camping Lantern",
    description: "Solar-powered LED camping lantern with power bank function and multiple brightness settings. Waterproof design.",
    price: 29.99,
    stock_quantity: 100,
    sku: "PCL-044",
    category: "Travel & Outdoor",
    active: true
  },
  {
    name: "Inflatable Travel Pillow",
    description: "Ergonomic inflatable travel pillow with memory foam top and compact carrying case. Perfect for long flights.",
    price: 19.99,
    stock_quantity: 150,
    sku: "ITP-045",
    category: "Travel & Outdoor",
    active: true
  },
  {
    name: "Waterproof Hiking Boots",
    description: "Durable waterproof hiking boots with ankle support and non-slip sole. Perfect for outdoor adventures.",
    price: 129.99,
    stock_quantity: 45,
    sku: "WHB-046",
    category: "Travel & Outdoor",
    active: true
  },
  # Health & Wellness
  {
    name: "Smart Blood Pressure Monitor",
    description: "Bluetooth-enabled blood pressure monitor with smartphone app and unlimited data storage. FDA approved.",
    price: 79.99,
    stock_quantity: 50,
    sku: "SBP-047",
    category: "Health & Wellness",
    active: true
  },
  {
    name: "Meditation Cushion Set",
    description: "Organic buckwheat meditation cushion with removable cover and matching mat. Perfect for mindfulness practice.",
    price: 39.99,
    stock_quantity: 65,
    sku: "MCS-048",
    category: "Health & Wellness",
    active: true
  },
  {
    name: "Air Purifier with HEPA Filter",
    description: "Smart air purifier with true HEPA filter, air quality sensor, and smartphone control. Covers 500 sq ft.",
    price: 159.99,
    stock_quantity: 30,
    sku: "APH-049",
    category: "Health & Wellness",
    active: true
  },
  {
    name: "Posture Corrector Brace",
    description: "Adjustable posture corrector brace with breathable material and discreet design. Improves spine alignment.",
    price: 24.99,
    stock_quantity: 90,
    sku: "PCB-050",
    category: "Health & Wellness",
    active: true
  },
  # Baby & Kids
  {
    name: "Baby Monitor with Video",
    description: "HD video baby monitor with night vision, two-way audio, and smartphone app. Peace of mind for parents.",
    price: 99.99,
    stock_quantity: 40,
    sku: "BMV-051",
    category: "Baby & Kids",
    active: true
  },
  {
    name: "Educational Building Blocks",
    description: "STEM educational building blocks set with 200 pieces and instruction guide. Develops creativity and problem-solving.",
    price: 34.99,
    stock_quantity: 85,
    sku: "EBB-052",
    category: "Baby & Kids",
    active: true
  },
  {
    name: "Kids Blue Light Glasses",
    description: "Blue light blocking glasses for kids with flexible frames and UV protection. Protects eyes from screen time.",
    price: 18.99,
    stock_quantity: 120,
    sku: "KBL-053",
    category: "Baby & Kids",
    active: true
  },
  {
    name: "Interactive Learning Tablet",
    description: "Kid-friendly learning tablet with educational games, parental controls, and durable case. Ages 3-8.",
    price: 79.99,
    stock_quantity: 55,
    sku: "ILT-054",
    category: "Baby & Kids",
    active: true
  },
  # More Electronics
  {
    name: "Wireless Earbuds Pro",
    description: "Premium wireless earbuds with active noise cancellation, 8-hour battery, and wireless charging case.",
    price: 149.99,
    stock_quantity: 60,
    sku: "WEP-055",
    category: "Electronics",
    active: true
  },
  {
    name: "Smart Home Security Camera",
    description: "WiFi security camera with 1080p HD, night vision, motion detection, and cloud storage. Easy setup.",
    price: 59.99,
    stock_quantity: 75,
    sku: "SHS-056",
    category: "Electronics",
    active: true
  },
  {
    name: "Portable Power Bank 20000mAh",
    description: "High-capacity power bank with fast charging, digital display, and multiple USB ports. Perfect for travel.",
    price: 39.99,
    stock_quantity: 100,
    sku: "PPB-057",
    category: "Electronics",
    active: true
  },
  {
    name: "Smart Doorbell with Camera",
    description: "Video doorbell with HD camera, two-way audio, motion alerts, and smartphone notifications. Easy installation.",
    price: 89.99,
    stock_quantity: 45,
    sku: "SDB-058",
    category: "Electronics",
    active: true
  },
  # More Home & Garden
  {
    name: "Robot Vacuum Cleaner",
    description: "Smart robot vacuum with mapping technology, app control, and automatic charging. Perfect for busy households.",
    price: 199.99,
    stock_quantity: 25,
    sku: "RVC-059",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Smart Thermostat WiFi",
    description: "Programmable WiFi thermostat with energy saving features and smartphone control. Easy DIY installation.",
    price: 129.99,
    stock_quantity: 35,
    sku: "STW-060",
    category: "Home & Garden",
    active: true
  },
  # Additional Electronics
  {
    name: "4K Webcam with Auto Focus",
    description: "Ultra HD webcam with auto focus, noise reduction microphone, and wide-angle lens. Perfect for streaming.",
    price: 79.99,
    stock_quantity: 65,
    sku: "4KW-061",
    category: "Electronics",
    active: true
  },
  {
    name: "Wireless Charging Stand",
    description: "Fast wireless charging stand with adjustable angle and LED indicator. Compatible with all Qi devices.",
    price: 34.99,
    stock_quantity: 85,
    sku: "WCS-062",
    category: "Electronics",
    active: true
  },
  {
    name: "Bluetooth Speaker Waterproof",
    description: "Portable waterproof Bluetooth speaker with 360-degree sound and 12-hour battery life.",
    price: 49.99,
    stock_quantity: 90,
    sku: "BSW-063",
    category: "Electronics",
    active: true
  },
  {
    name: "USB-C to HDMI Adapter",
    description: "4K USB-C to HDMI adapter supporting 60Hz refresh rate. Plug and play compatibility.",
    price: 19.99,
    stock_quantity: 120,
    sku: "UCH-064",
    category: "Electronics",
    active: true
  },
  {
    name: "Wireless Keyboard Compact",
    description: "Slim wireless keyboard with quiet keys and long battery life. Perfect for tablets and laptops.",
    price: 39.99,
    stock_quantity: 75,
    sku: "WKC-065",
    category: "Electronics",
    active: true
  },
  # Additional Home & Garden
  {
    name: "Smart Smoke Detector",
    description: "WiFi smoke detector with smartphone alerts, voice alarms, and 10-year battery life.",
    price: 89.99,
    stock_quantity: 40,
    sku: "SSD-066",
    category: "Home & Garden",
    active: true
  },
  {
    name: "LED Strip Lights 16ft",
    description: "RGB LED strip lights with remote control, music sync, and app control. Easy installation.",
    price: 24.99,
    stock_quantity: 110,
    sku: "LSL-067",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Garden Hose Expandable",
    description: "50ft expandable garden hose with 9-function spray nozzle. Lightweight and kink-free.",
    price: 29.99,
    stock_quantity: 95,
    sku: "GHE-068",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Indoor Security Camera",
    description: "1080p indoor security camera with night vision, two-way audio, and motion detection.",
    price: 39.99,
    stock_quantity: 80,
    sku: "ISC-069",
    category: "Home & Garden",
    active: true
  },
  {
    name: "Smart Light Switch",
    description: "WiFi smart light switch with voice control and scheduling. No hub required.",
    price: 19.99,
    stock_quantity: 100,
    sku: "SLS-070",
    category: "Home & Garden",
    active: true
  },
  # Additional Sports & Fitness
  {
    name: "Adjustable Dumbbells Set",
    description: "Space-saving adjustable dumbbells with quick-change weight system. 5-50 lbs per dumbbell.",
    price: 299.99,
    stock_quantity: 20,
    sku: "ADS-071",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Exercise Bike Foldable",
    description: "Compact foldable exercise bike with LCD monitor and 8 resistance levels. Perfect for home workouts.",
    price: 159.99,
    stock_quantity: 25,
    sku: "EBF-072",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Protein Shaker Bottle",
    description: "BPA-free protein shaker with mixing ball and measurement marks. Leak-proof design.",
    price: 12.99,
    stock_quantity: 150,
    sku: "PSB-073",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Running Armband Phone Holder",
    description: "Adjustable running armband for smartphones with key holder and reflective strips.",
    price: 14.99,
    stock_quantity: 130,
    sku: "RAP-074",
    category: "Sports & Fitness",
    active: true
  },
  {
    name: "Balance Board Trainer",
    description: "Wooden balance board for core strength training and rehabilitation. Non-slip surface.",
    price: 39.99,
    stock_quantity: 60,
    sku: "BBT-075",
    category: "Sports & Fitness",
    active: true
  },
  # Additional Fashion & Accessories
  {
    name: "Leather Wallet RFID Blocking",
    description: "Genuine leather wallet with RFID blocking technology and multiple card slots. Slim design.",
    price: 34.99,
    stock_quantity: 85,
    sku: "LWR-076",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Sunglasses Polarized UV400",
    description: "Stylish polarized sunglasses with UV400 protection and lightweight frame. Unisex design.",
    price: 29.99,
    stock_quantity: 95,
    sku: "SPU-077",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Crossbody Bag Canvas",
    description: "Durable canvas crossbody bag with multiple pockets and adjustable strap. Perfect for travel.",
    price: 24.99,
    stock_quantity: 70,
    sku: "CBC-078",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Watch Band Silicone Sport",
    description: "Comfortable silicone sport watch band with quick release pins. Available in multiple colors.",
    price: 16.99,
    stock_quantity: 120,
    sku: "WBS-079",
    category: "Fashion & Accessories",
    active: true
  },
  {
    name: "Baseball Cap Adjustable",
    description: "Classic adjustable baseball cap with embroidered logo and curved brim. 100% cotton.",
    price: 19.99,
    stock_quantity: 110,
    sku: "BCA-080",
    category: "Fashion & Accessories",
    active: true
  },
  # Additional Kitchen & Dining
  {
    name: "Air Fryer 6 Quart",
    description: "Large capacity air fryer with digital controls and 8 preset cooking programs. Oil-free cooking.",
    price: 89.99,
    stock_quantity: 45,
    sku: "AF6-081",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Insulated Lunch Box",
    description: "Leak-proof insulated lunch box with multiple compartments and ice pack. BPA-free materials.",
    price: 22.99,
    stock_quantity: 90,
    sku: "ILB-082",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Silicone Baking Mats Set",
    description: "Non-stick silicone baking mats set of 3. Reusable and dishwasher safe. Perfect for cookies and pastries.",
    price: 18.99,
    stock_quantity: 100,
    sku: "SBM-083",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Electric Kettle Stainless Steel",
    description: "1.7L electric kettle with auto shut-off, boil-dry protection, and LED indicator. Fast boiling.",
    price: 34.99,
    stock_quantity: 65,
    sku: "EKS-084",
    category: "Kitchen & Dining",
    active: true
  },
  {
    name: "Food Storage Containers Glass",
    description: "Set of 10 glass food storage containers with airtight lids. Microwave and dishwasher safe.",
    price: 39.99,
    stock_quantity: 75,
    sku: "FSC-085",
    category: "Kitchen & Dining",
    active: true
  },
  # Additional Books & Media
  {
    name: "Productivity Planner 2024",
    description: "Daily productivity planner with goal setting, habit tracking, and reflection pages. Undated format.",
    price: 24.99,
    stock_quantity: 80,
    sku: "PP2-086",
    category: "Books & Media",
    active: true
  },
  {
    name: "Bluetooth CD Player Portable",
    description: "Portable CD player with Bluetooth connectivity, anti-skip protection, and rechargeable battery.",
    price: 49.99,
    stock_quantity: 55,
    sku: "BCD-087",
    category: "Books & Media",
    active: true
  },
  {
    name: "Audiobook Subscription Gift Card",
    description: "3-month audiobook subscription gift card with access to thousands of titles. Perfect gift.",
    price: 44.99,
    stock_quantity: 200,
    sku: "ASG-088",
    category: "Books & Media",
    active: true
  },
  {
    name: "Reading Light Clip-On LED",
    description: "Rechargeable clip-on LED reading light with adjustable brightness and flexible neck.",
    price: 16.99,
    stock_quantity: 115,
    sku: "RLC-089",
    category: "Books & Media",
    active: true
  },
  {
    name: "Journal Leather Bound",
    description: "Premium leather-bound journal with lined pages and elastic closure. Perfect for writing and sketching.",
    price: 29.99,
    stock_quantity: 70,
    sku: "JLB-090",
    category: "Books & Media",
    active: true
  }
]

puts "Creating sample products..."

products.each do |product_attrs|
  # Find the category by name
  category = Category.find_by(name: product_attrs[:category])
  
  if category.nil?
    puts "⚠ Warning: Category '#{product_attrs[:category]}' not found for product '#{product_attrs[:name]}'"
  end
  
  product = Product.find_or_create_by(sku: product_attrs[:sku]) do |p|
    p.name = product_attrs[:name]
    p.description = product_attrs[:description]
    p.price = product_attrs[:price]
    p.stock_quantity = product_attrs[:stock_quantity]
    p.category = category
    p.active = product_attrs[:active]
  end
  
  if product.persisted?
    puts "✓ Created product: #{product.name} (Category: #{product.category&.name || 'None'})"
  else
    puts "✗ Failed to create product: #{product_attrs[:name]} - #{product.errors.full_messages.join(', ')}"
  end
end

puts "Seed data creation completed!"
puts "Created #{Product.count} products total."
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?