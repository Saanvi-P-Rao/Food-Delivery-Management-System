-- ============================================================================
-- FoodExpress - Realistic Interconnected Indian Food Delivery Seed Data
-- Idempotent: Safe to re-run without creating duplicate records.
-- Demo account password for all seeded Users, Restaurants, and Admins:
--   FoodExpress@123
-- ============================================================================

USE food_delivery_db;

SET @DEMO_HASH = 'pbkdf2:65536:1a2b3c4d5e6f708192a3b4c5d6e7f809:d22686eb9569de4f4724825bb7ec5c6a6efb0ffd7398f26255c3352facb702be';

-- ----------------------------------------------------------------------------
-- 1. ADMIN (2 Administrators)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Admin` (admin_id, username, full_name, email, password_hash, role) VALUES
(1, 'superadmin', 'Arjun Mehta', 'admin@foodexpress.in', @DEMO_HASH, 'SUPER_ADMIN'),
(2, 'dbadmin',    'Kavya Iyer',  'dba@foodexpress.in',   @DEMO_HASH, 'DB_ADMIN');

-- ----------------------------------------------------------------------------
-- 2. USER (50 Customers across major Indian cities)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Users` (user_id, full_name, email, phone, password_hash, address, city, pincode) VALUES
(1,  'Aarav Sharma',       'aarav.sharma@example.in',       '9876543201', @DEMO_HASH, '12 MG Road, Indiranagar',             'Bengaluru', '560038'),
(2,  'Diya Patel',         'diya.patel@example.in',         '9876543202', @DEMO_HASH, '45 Linking Road, Bandra West',        'Mumbai',    '400050'),
(3,  'Rohan Verma',        'rohan.verma@example.in',        '9876543203', @DEMO_HASH, '78 Connaught Place, Block B',         'New Delhi', '110001'),
(4,  'Ananya Nair',        'ananya.nair@example.in',        '9876543204', @DEMO_HASH, '23 Jubilee Hills, Road No 36',        'Hyderabad', '500033'),
(5,  'Vikram Singh',       'vikram.singh@example.in',       '9876543205', @DEMO_HASH, '90 Koregaon Park, Lane 7',            'Pune',      '411001'),
(6,  'Sneha Reddy',        'sneha.reddy@example.in',        '9876543206', @DEMO_HASH, '14 Anna Nagar East, 2nd Ave',         'Chennai',   '600102'),
(7,  'Karan Malhotra',     'karan.malhotra@example.in',     '9876543207', @DEMO_HASH, '56 Koramangala 4th Block',            'Bengaluru', '560034'),
(8,  'Pooja Joshi',        'pooja.joshi@example.in',        '9876543208', @DEMO_HASH, '88 Powai Lake View, Hiranandani',     'Mumbai',    '400076'),
(9,  'Aditya Kulkarni',    'aditya.kulkarni@example.in',    '9876543209', @DEMO_HASH, '31 FC Road, Shivajinagar',            'Pune',      '411004'),
(10, 'Meera Krishnan',     'meera.krishnan@example.in',     '9876543210', @DEMO_HASH, '67 Besant Nagar, Elliott Beach Rd',   'Chennai',   '600090'),
(11, 'Siddharth Gupta',    'siddharth.gupta@example.in',    '9876543211', @DEMO_HASH, '19 Hauz Khas Village',                'New Delhi', '110016'),
(12, 'Neha Kapoor',        'neha.kapoor@example.in',        '9876543212', @DEMO_HASH, '42 Banjara Hills, Road No 12',        'Hyderabad', '500034'),
(13, 'Rahul Deshmukh',     'rahul.deshmukh@example.in',     '9876543213', @DEMO_HASH, '73 Whitefield Main Road',             'Bengaluru', '560066'),
(14, 'Ishita Chatterjee',  'ishita.chatterjee@example.in',  '9876543214', @DEMO_HASH, '15 Park Street, Camac St',            'Kolkata',   '700016'),
(15, 'Nikhil Agarwal',     'nikhil.agarwal@example.in',     '9876543215', @DEMO_HASH, '29 C-Scheme, Ashok Marg',             'Jaipur',    '302001'),
(16, 'Tanvi Bhatia',       'tanvi.bhatia@example.in',       '9876543216', @DEMO_HASH, '64 Sector 17 Plaza',                  'Chandigarh','160017'),
(17, 'Varun Menon',        'varun.menon@example.in',        '9876543217', @DEMO_HASH, '81 HSR Layout Sector 2',              'Bengaluru', '560102'),
(18, 'Riya Saxena',        'riya.saxena@example.in',        '9876543218', @DEMO_HASH, '10 Gomti Nagar, Vibhuti Khand',       'Lucknow',   '226010'),
(19, 'Arnav Choudhary',    'arnav.choudhary@example.in',    '9876543219', @DEMO_HASH, '37 Cyber Hub, DLF Phase 2',           'Gurugram',  '122002'),
(20, 'Simran Kaur',        'simran.kaur@example.in',        '9876543220', @DEMO_HASH, '52 Model Town Extension',             'Ludhiana',  '141002'),
(21, 'Pranav Rao',         'pranav.rao@example.in',         '9876543221', @DEMO_HASH, '28 Jayanagar 3rd Block',              'Bengaluru', '560011'),
(22, 'Divya Iyer',         'divya.iyer@example.in',         '9876543222', @DEMO_HASH, '94 Adyar, Gandhi Nagar',              'Chennai',   '600020'),
(23, 'Manish Tiwari',      'manish.tiwari@example.in',      '9876543223', @DEMO_HASH, '18 Vijay Nagar Square',               'Indore',    '452010'),
(24, 'Shruti Bansal',      'shruti.bansal@example.in',      '9876543224', @DEMO_HASH, '71 Sector 62, Institutional Area',    'Noida',     '201309'),
(25, 'Harsh Vardhan',      'harsh.vardhan@example.in',      '9876543225', @DEMO_HASH, '33 Boring Road, Sri Krishnapuri',     'Patna',     '800001'),
(26, 'Kavita Hegde',       'kavita.hegde@example.in',       '9876543226', @DEMO_HASH, '49 Malleswaram 8th Cross',            'Bengaluru', '560003'),
(27, 'Deepak Mishra',      'deepak.mishra@example.in',      '9876543227', @DEMO_HASH, '62 Civil Lines, MG Marg',             'Prayagraj', '211001'),
(28, 'Nandini Bose',       'nandini.bose@example.in',       '9876543228', @DEMO_HASH, '85 Salt Lake Sector V',               'Kolkata',   '700091'),
(29, 'Saurabh Jain',       'saurabh.jain@example.in',       '9876543229', @DEMO_HASH, '11 Malviya Nagar, JLN Marg',          'Jaipur',    '302017'),
(30, 'Aditi Kulkarni',     'aditi.kulkarni@example.in',     '9876543230', @DEMO_HASH, '44 Kothrud, Paud Road',               'Pune',      '411038'),
(31, 'Yashwant Shetty',    'yashwant.shetty@example.in',    '9876543231', @DEMO_HASH, '77 Andheri West, Lokhandwala',        'Mumbai',    '400053'),
(32, 'Bhavna Trivedi',     'bhavna.trivedi@example.in',     '9876543232', @DEMO_HASH, '25 Satellite Road, Prahlad Nagar',    'Ahmedabad', '380015'),
(33, 'Gaurav Khanna',      'gaurav.khanna@example.in',      '9876543233', @DEMO_HASH, '58 Rajouri Garden, Main Market',      'New Delhi', '110027'),
(34, 'Swati Deshpande',    'swati.deshpande@example.in',    '9876543234', @DEMO_HASH, '91 Viman Nagar, Datta Mandir',        'Pune',      '411014'),
(35, 'Tarun Gill',         'tarun.gill@example.in',         '9876543235', @DEMO_HASH, '16 Sector 35-C Market',               'Chandigarh','160022'),
(36, 'Pallavi Gokhale',    'pallavi.gokhale@example.in',    '9876543236', @DEMO_HASH, '39 Dadar West, Shivaji Park',         'Mumbai',    '400028'),
(37, 'Abhishek Pandey',    'abhishek.pandey@example.in',    '9876543237', @DEMO_HASH, '83 Hazratganj, Ashok Marg',           'Lucknow',   '226001'),
(38, 'Ritika Sood',        'ritika.sood@example.in',        '9876543238', @DEMO_HASH, '21 Greater Kailash Part 1',           'New Delhi', '110048'),
(39, 'Karthik Subramanian','karthik.sub@example.in',        '9876543239', @DEMO_HASH, '68 T Nagar, Usman Road',              'Chennai',   '600017'),
(40, 'Nisha Acharya',      'nisha.acharya@example.in',      '9876543240', @DEMO_HASH, '47 Madhapur, Hitech City',            'Hyderabad', '500081'),
(41, 'Vivek Nambiar',      'vivek.nambiar@example.in',      '9876543241', @DEMO_HASH, '13 JP Nagar 7th Phase',               'Bengaluru', '560078'),
(42, 'Anjali Sengupta',    'anjali.sengupta@example.in',    '9876543242', @DEMO_HASH, '76 Ballygunge Place',                 'Kolkata',   '700019'),
(43, 'Mohit Chauhan',      'mohit.chauhan@example.in',      '9876543243', @DEMO_HASH, '30 Golf Course Road, Sector 54',      'Gurugram',  '122011'),
(44, 'Shreya Kulkarni',    'shreya.k@example.in',           '9876543244', @DEMO_HASH, '55 Aundh, ITI Road',                  'Pune',      '411007'),
(45, 'Rajeshwari Pillai',  'rajeshwari.p@example.in',       '9876543245', @DEMO_HASH, '89 Gachibowli, Financial District',   'Hyderabad', '500032'),
(46, 'Sandeep Yadav',      'sandeep.yadav@example.in',      '9876543246', @DEMO_HASH, '24 Sector 18 Market',                 'Noida',     '201301'),
(47, 'Preeti Rawat',       'preeti.rawat@example.in',       '9876543247', @DEMO_HASH, '61 Vasant Kunj, Pocket C',            'New Delhi', '110070'),
(48, 'Ashwin Prabhu',      'ashwin.prabhu@example.in',      '9876543248', @DEMO_HASH, '34 Lower Parel, Senapati Bapat Marg', 'Mumbai',    '400013'),
(49, 'Lakshmi Narayanan',  'lakshmi.n@example.in',          '9876543249', @DEMO_HASH, '92 Mylapore, Luz Church Rd',          'Chennai',   '600004'),
(50, 'Devansh Bhatt',      'devansh.bhatt@example.in',      '9876543250', @DEMO_HASH, '17 Navrangpura, CG Road',             'Ahmedabad', '380009');

-- ----------------------------------------------------------------------------
-- 3. Restaurants (15 Indian Restaurants)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Restaurants` (restaurant_id, name, email, phone, password_hash, cuisine_type, description, address, city, rating, delivery_time_mins, image_url, is_active) VALUES
(1,  'Spice Garden Kitchen',   'spicegarden@foodexpress.in',   '08041110001', @DEMO_HASH, 'North Indian',      'Authentic tandoor, rich curries, and slow-cooked dals.',                  '100 Feet Rd, Indiranagar',         'Bengaluru', 4.70, 28, 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800&q=80', TRUE),
(2,  'Biryani Blues Royal',    'biryaniblues@foodexpress.in',  '04041110002', @DEMO_HASH, 'Hyderabadi Biryani','Dum-cooked Hyderabadi biryanis with aged basmati and saffron.',           'Road No 12, Banjara Hills',        'Hyderabad', 4.80, 32, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800&q=80', TRUE),
(3,  'Dosa Plaza Express',     'dosaplaza@foodexpress.in',     '04441110003', @DEMO_HASH, 'South Indian',      'Crispy ghee roasts, filter coffee, and traditional idli-vada.',           '2nd Ave, Anna Nagar',              'Chennai',   4.60, 22, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=800&q=80', TRUE),
(4,  'Tandoor Tales',          'tandoortales@foodexpress.in',  '01141110004', @DEMO_HASH, 'Mughlai & Kebabs',  'Charcoal-grilled kebabs, butter chicken, and flaky naans.',               'Block M, Connaught Place',         'New Delhi', 4.65, 35, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=800&q=80', TRUE),
(5,  'Mumbai Chaat House',     'mumbaichaat@foodexpress.in',   '02241110005', @DEMO_HASH, 'Street Food',       'Iconic vada pav, pav bhaji, pani puri, and Mumbai street classics.',      'Hill Road, Bandra West',           'Mumbai',    4.55, 20, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=800&q=80', TRUE),
(6,  'Punjabi Dhaba Junction', 'punjabidhaba@foodexpress.in',  '01724110006', @DEMO_HASH, 'Punjabi',           'Hearty sarson da saag, makki roti, lassi, and dhaba-style thalis.',       'Sector 17-E',                      'Chandigarh','4.50', 30, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&q=80', TRUE),
(7,  'Coastal Spice Curry',    'coastalspice@foodexpress.in',  '02241110007', @DEMO_HASH, 'Coastal & Seafood', 'Malvani fish curry, appam with stew, and coconut-infused delicacies.',    'Juhu Tara Road',                   'Mumbai',    4.75, 38, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800&q=80', TRUE),
(8,  'Wok & Roll Express',     'wokandroll@foodexpress.in',    '08041110008', @DEMO_HASH, 'Indo-Chinese',      'Smoky hakka noodles, chilli paneer, manchurian, and dim sum bowls.',      '80 Feet Rd, Koramangala',          'Bengaluru', 4.40, 25, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800&q=80', TRUE),
(9,  'Pizza Craft India',      'pizzacraft@foodexpress.in',    '02041110009', @DEMO_HASH, 'Wood-Fired Pizza',  'Sourdough wood-fired pizzas with desi tikka & gourmet toppings.',         'Lane 7, Koregaon Park',            'Pune',      4.60, 27, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80', TRUE),
(10, 'Green Bowl Organics',    'greenbowl@foodexpress.in',     '08041110010', @DEMO_HASH, 'Healthy & Salads',  'High-protein millet bowls, cold-pressed juices, and wholesome salads.',   'HSR Layout Sector 2',              'Bengaluru', 4.50, 24, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80', TRUE),
(11, 'Royal Mughlai Darbar',   'royalmughlai@foodexpress.in',  '05224110011', @DEMO_HASH, 'Awadhi & Mughlai',  'Galouti kebabs, Lucknowi biryani, and shahi tukda.',                     'Hazratganj Main Rd',               'Lucknow',   4.85, 34, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800&q=80', TRUE),
(12, 'Sweet Tooth Mithai',     'sweettooth@foodexpress.in',    '01414110012', @DEMO_HASH, 'Desserts & Mithai', 'Fresh gulab jamun, rasmalai, kaju katli, and artisanal kulfi.',          'MI Road, C-Scheme',                'Jaipur',    4.75, 20, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=800&q=80', TRUE),
(13, 'Chai & Snacks Co.',      'chaisnacks@foodexpress.in',    '02041110013', @DEMO_HASH, 'Cafe & Beverages',  'Masala chai flasks, bun maska, samosas, and cold brews.',                 'FC Road, Shivajinagar',            'Pune',      4.45, 18, 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?w=800&q=80', TRUE),
(14, 'Curry Kingdom',          'currykingdom@foodexpress.in',  '03341110014', @DEMO_HASH, 'Bengali & Eastern', 'Kosha mangsho, shorshe ilish, mishti doi, and luchi platters.',          'Park Street',                      'Kolkata',   4.70, 32, 'https://images.unsplash.com/photo-1505253758473-96b7015fcd40?w=800&q=80', TRUE),
(15, 'Grill Masters BBQ',      'grillmasters@foodexpress.in',  '01244110015', @DEMO_HASH, 'BBQ & Burgers',     'Peri-peri grilled platters, gourmet smash burgers, and loaded fries.',    'Cyber Hub, DLF Phase 2',           'Gurugram',  4.55, 29, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80', TRUE);

-- ----------------------------------------------------------------------------
-- 4. Food_Items (100 Items across the 15 Restaurants, INR Pricing)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Food_Items` (food_id, restaurant_id, name, description, category, price, is_veg, is_available, image_url) VALUES
-- Restaurants 1: Spice Garden Kitchen (7 items)
(1,  1, 'Paneer Butter Masala',       'Cottage cheese simmered in creamy tomato-cashew gravy.',         'Main Course', 299.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=80'),
(2,  1, 'Dal Makhani',                '24-hour slow-cooked black lentils finished with white butter.',  'Main Course', 259.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&q=80'),
(3,  1, 'Garlic Butter Naan',         'Soft tandoori flatbread brushed with roasted garlic butter.',    'Breads',       79.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(4,  1, 'Paneer Tikka Platter',       'Char-grilled cottage cheese cubes marinated in yogurt spices.',  'Starters',    279.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&q=80'),
(5,  1, 'Chicken Tikka Masala',       'Roasted chicken tikka tossed in spiced onion-tomato masala.',    'Main Course', 349.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80'),
(6,  1, 'Jeera Pulao',                'Fragrant cumin-tempered basmati rice.',                          'Rice',        179.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&q=80'),
(7,  1, 'Mango Lassi',                'Thick Alphonso mango yogurt smoothie.',                          'Beverages',   129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=600&q=80'),

-- Restaurants 2: Biryani Blues Royal (7 items)
(8,  2, 'Hyderabadi Chicken Dum Biryani', 'Classic kacchi dum biryani served with mirchi ka salan & raita.', 'Biryani', 349.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80'),
(9,  2, 'Mutton Zafrani Biryani',     'Tender mutton pieces layered with saffron basmati rice.',         'Biryani',     449.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1642821373181-696a54913e93?w=600&q=80'),
(10, 2, 'Subz Dum Handi Biryani',     'Mixed vegetables & paneer dum-cooked in aromatic spices.',       'Biryani',     279.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600&q=80'),
(11, 2, 'Chicken 65',                 'Crispy spicy South-style fried chicken tempered with curry leaves.','Starters',   289.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&q=80'),
(12, 2, 'Double Ka Meetha',           'Hyderabadi saffron bread pudding topped with pistachios.',       'Desserts',    159.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),
(13, 2, 'Paneer 65',                  'Crispy spiced paneer cubes tossed with green chillies.',          'Starters',    249.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&q=80'),
(14, 2, 'Mint Chaas',                 'Refreshing spiced buttermilk with roasted cumin.',               'Beverages',    89.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&q=80'),

-- Restaurants 3: Dosa Plaza Express (7 items)
(15, 3, 'Mysore Masala Dosa',         'Crispy crepe layered with spicy red chutney & potato masala.',   'South Indian',169.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=600&q=80'),
(16, 3, 'Ghee Podi Idli (3 Pcs)',     'Steamed idlis tossed in aromatic gunpowder & pure cow ghee.',    'South Indian',139.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&q=80'),
(17, 3, 'Medu Vada (3 Pcs)',          'Golden crispy lentil doughnuts with coconut chutney & sambar.',  'South Indian',119.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&q=80'),
(18, 3, 'Rava Onion Uttapam',         'Savory semolina pancake topped with caramelized onions.',       'South Indian',159.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=600&q=80'),
(19, 3, 'Madras Filter Coffee',       'Traditional decoction coffee frothed in brass davara.',          'Beverages',    79.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600&q=80'),
(20, 3, 'Curd Rice Tadka',            'Creamy yogurt rice tempered with mustard seeds & pomegranate.',  'South Indian',149.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&q=80'),
(21, 3, 'Chettinad Chicken Roast',    'Fiery pepper-roasted chicken with freshly ground spices.',       'Main Course', 319.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600&q=80'),

-- Restaurants 4: Tandoor Tales (7 items)
(22, 4, 'Old Delhi Butter Chicken',   'Tandoori chicken simmered in velvety tomato-fenugreek gravy.',   'Main Course', 369.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600&q=80'),
(23, 4, 'Mutton Seekh Kebab',         'Skewered minced lamb seasoned with mint and royal spices.',      'Starters',    389.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80'),
(24, 4, 'Tandoori Chicken (Half)',    'Classic smoky yogurt-marinated chicken roasted in clay oven.',   'Starters',    329.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80'),
(25, 4, 'Amritsari Kulcha',           'Stuffed potato-paneer kulcha served with chole.',                'Breads',      149.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(26, 4, 'Kadai Paneer',               'Cottage cheese & bell peppers tossed in crushed coriander.',     'Main Course', 289.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=80'),
(27, 4, 'Lachha Paratha',             'Flaky multi-layered whole wheat tandoori bread.',                'Breads',       69.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(28, 4, 'Phirni Clay Pot',            'Chilled ground rice pudding infused with cardamom & rose.',      'Desserts',    139.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),

-- Restaurants 5: Mumbai Chaat House (7 items)
(29, 5, 'Butter Pav Bhaji',           'Spiced mashed vegetable bhaji served with 2 Amul buttered pavs.',  'Street Food', 179.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80'),
(30, 5, 'Bombay Vada Pav (2 Pcs)',    'Crispy batata vada tucked in soft pav with dry garlic chutney.', 'Street Food',  99.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80'),
(31, 5, 'Dahi Puri Chaat',            'Crispy puris stuffed with potatoes, sweet curd & chutneys.',     'Street Food', 129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(32, 5, 'Tawa Pulao',                 'Mumbai street-style spiced rice cooked on flat griddle.',        'Rice',        189.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&q=80'),
(33, 5, 'Cheese Grill Sandwich',      'Triple-decker Bombay masala toast with melted cheese.',          'Street Food', 169.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600&q=80'),
(34, 5, 'Kala Khatta Slush',          'Tangy jamun-flavored Mumbai street cooler.',                     'Beverages',    99.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&q=80'),
(35, 5, 'Sev Puri',                   'Flat puris loaded with tangy chutneys, onions, and fine sev.',   'Street Food', 119.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80'),

-- Restaurants 6: Punjabi Dhaba Junction (7 items)
(36, 6, 'Sarson Da Saag & Makki Roti','Winter specialty mustard greens served with 2 corn flatbreads.', 'Main Course', 269.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&q=80'),
(37, 6, 'Pindi Chole Bhature',        'Spiced chickpeas paired with 2 fluffy golden bhaturas.',         'Main Course', 199.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&q=80'),
(38, 6, 'Dhaba Chicken Curry',        'Rustic bone-in chicken curry cooked with whole garam masala.',   'Main Course', 339.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600&q=80'),
(39, 6, 'Rajma Chawal Bowl',          'Comforting red kidney bean curry over steamed basmati rice.',    'Rice',        189.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&q=80'),
(40, 6, 'Patiala Sweet Lassi',        'Tall earthen glass of creamy churned sweet lassi.',              'Beverages',   109.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1527661591475-527312dd65f5?w=600&q=80'),
(41, 6, 'Tandoori Stuffed Paratha',   'Aloo-pyaz paratha served with curd and mango pickle.',           'Breads',      129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(42, 6, 'Moong Dal Halwa',            'Rich slow-roasted lentil halwa garnished with almonds.',         'Desserts',    169.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),

-- Restaurants 7: Coastal Spice Curry (7 items)
(43, 7, 'Malvani Surmai Curry',       'Kingfish simmered in tangy coconut-kokum Malvani gravy.',        'Main Course', 429.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&q=80'),
(44, 7, 'Prawn Ghee Roast',           'Juicy prawns roasted in fiery Kundapur masala and ghee.',        'Starters',    449.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80'),
(45, 7, 'Appam with Veg Stew',        'Lacy fermented rice hoppers with mild coconut milk stew.',       'South Indian',229.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=600&q=80'),
(46, 7, 'Neer Dosa & Chicken Sukka',  'Delicate rice crepes paired with dry spiced Mangalorean chicken.','Main Course', 349.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&q=80'),
(47, 7, 'Sol Kadhi',                  'Cooling pink kokum and coconut milk digestive drink.',           'Beverages',    99.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&q=80'),
(48, 7, 'Crab Pepper Fry',            'Fresh crab tossed with crushed black pepper and curry leaves.',  'Starters',    489.00, FALSE, FALSE,'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&q=80'),
(49, 7, 'Tender Coconut Payasam',     'Chilled Kerala-style tender coconut milk pudding.',              'Desserts',    159.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),

-- Restaurants 8: Wok & Roll Express (7 items)
(50, 8, 'Veg Hakka Noodles',          'Wok-tossed noodles with crisp bell peppers, cabbage & soy.',     'Chinese',     219.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&q=80'),
(51, 8, 'Chilli Paneer Dry',          'Crispy paneer tossed in fiery garlic-soy chilli sauce.',         'Starters',    249.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&q=80'),
(52, 8, 'Chicken Schezwan Fried Rice','Spicy wok-fried rice with shredded chicken and Schezwan sauce.', 'Chinese',     269.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&q=80'),
(53, 8, 'Veg Manchurian Gravy',       'Vegetable dumplings in rich Indo-Chinese garlic-coriander gravy.','Chinese',    229.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&q=80'),
(54, 8, 'Crispy Honey Chilli Potato', 'Golden potato fingers glazed with honey, chilli & sesame.',      'Starters',    199.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&q=80'),
(55, 8, 'Chicken Momos (8 Pcs)',      'Steamed Himalayan dumplings served with fiery red chutney.',     'Starters',    189.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600&q=80'),
(56, 8, 'Iced Peach Tea',             'Chilled brewed black tea infused with peach puree.',             'Beverages',   119.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&q=80'),

-- Restaurants 9: Pizza Craft India (7 items)
(57, 9, 'Tandoori Paneer Pizza (10")','Wood-fired sourdough topped with smoky paneer tikka & makhani.', 'Pizza',       399.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80'),
(58, 9, 'Classic Margherita (10")',   'San Marzano tomato sauce, fresh mozzarella & basil leaves.',     'Pizza',       329.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&q=80'),
(59, 9, 'Chicken Keema Supreme (10")','Spiced minced chicken, jalapenos, red onions & mozzarella.',     'Pizza',       449.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80'),
(60, 9, 'Cheesy Garlic Breadsticks',  'Oven-baked sourdough sticks brushed with herb garlic butter.',   'Starters',    179.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1573140247632-f8fd74997d5c?w=600&q=80'),
(61, 9, 'Penne Arrabbiata',           'Penne pasta tossed in spicy garlic tomato basil sauce.',         'Pasta',       289.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1555949258-eb67b1ef0ceb?w=600&q=80'),
(62, 9, 'Tiramisu Cup',               'Espresso-soaked sponge layered with mascarpone cream.',          'Desserts',    219.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=600&q=80'),
(63, 9, 'Virgin Mint Mojito',         'Sparkling lime and fresh mint cooler.',                          'Beverages',   129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=600&q=80'),

-- Restaurants 10: Green Bowl Organics (6 items)
(64, 10,'Quinoa & Grilled Paneer Bowl','Protein-rich quinoa with roasted veggies, paneer & tahini.',    'Healthy',     319.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80'),
(65, 10,'Herb Grilled Chicken Salad', 'Mixed greens, cherry tomatoes, avocado & grilled chicken breast.','Healthy',    349.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80'),
(66, 10,'Avocado Sourdough Toast',    'Smashed Hass avocado, microgreens & feta on toasted sourdough.', 'Healthy',     269.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80'),
(67, 10,'Cold-Pressed ABC Juice',     'Freshly pressed Apple, Beetroot & Carrot detox juice.',          'Beverages',   149.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=600&q=80'),
(68, 10,'Chia Berry Smoothie Bowl',   'Blended berries topped with granola, chia seeds & banana.',      'Desserts',    249.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600&q=80'),
(69, 10,'Millet Khichdi Bowl',        'Comforting foxtail millet khichdi with tempered ghee.',          'Healthy',     229.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80'),

-- Restaurants 11: Royal Mughlai Darbar (6 items)
(70, 11,'Lucknowi Galouti Kebab',     'Melt-in-mouth minced lamb kebabs served with ulte tawe ka paratha.','Starters',399.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80'),
(71, 11,'Awadhi Mutton Biryani',      'Fragrant slow-cooked Lucknowi dum biryani with kewra essence.',    'Biryani',     439.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80'),
(72, 11,'Murgh Musallam',             'Royal spiced chicken in rich almond-saffron gravy.',             'Main Course', 389.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80'),
(73, 11,'Shahi Paneer Korma',         'Cottage cheese cooked in creamy white saffron-cashew gravy.',    'Main Course', 309.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=80'),
(74, 11,'Sheermal',                   'Sweet saffron-brushed traditional Lucknowi flatbread.',          'Breads',       99.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(75, 11,'Shahi Tukda',                'Crisp fried bread soaked in saffron rabri & dry fruits.',        'Desserts',    189.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),

-- Restaurants 12: Sweet Tooth Mithai (6 items)
(76, 12,'Hot Gulab Jamun (4 Pcs)',    'Soft khoya dumplings soaked in warm rose-cardamom syrup.',       'Desserts',    129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),
(77, 12,'Kesar Rasmalai (3 Pcs)',     'Flattened chenna discs in chilled saffron-pistachio milk.',      'Desserts',    169.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),
(78, 12,'Kaju Katli Box (250g)',      'Silky cashew fudge topped with edible silver leaf.',             'Desserts',    349.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1605197161470-5d2a9af0ac7e?w=600&q=80'),
(79, 12,'Matka Malai Kulfi',          'Dense slow-reduced milk kulfi served in an earthen pot.',        'Desserts',    139.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600&q=80'),
(80, 12,'Motichoor Ladoo (4 Pcs)',    'Pure ghee boondi ladoos studded with melon seeds.',             'Desserts',    149.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1605197161470-5d2a9af0ac7e?w=600&q=80'),
(81, 12,'Badam Thandai',              'Chilled spiced almond milk with rose petals & fennel.',          'Beverages',   129.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&q=80'),

-- Restaurants 13: Chai & Snacks Co. (6 items)
(82, 13,'Adrak Masala Chai Flask',    'Serves 3: Freshly brewed ginger-cardamom Assam tea.',            'Beverages',   149.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?w=600&q=80'),
(83, 13,'Irani Bun Maska',            'Warm sweet milk bun slathered with whipped butter.',             'Street Food',  89.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&q=80'),
(84, 13,'Punjabi Samosa (2 Pcs)',     'Flaky pastry triangles stuffed with spiced potatoes & peas.',    'Street Food',  79.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(85, 13,'Kanda Bhajiya Platter',      'Crispy onion fritters served with mint chutney.',                'Street Food', 119.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80'),
(86, 13,'Classic Cold Coffee',        'Blended espresso, chilled milk & vanilla ice cream.',            'Beverages',   159.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600&q=80'),
(87, 13,'Chocolate Walnut Brownie',   'Fudgy dark chocolate brownie loaded with toasted walnuts.',      'Desserts',    139.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=600&q=80'),

-- Restaurants 14: Curry Kingdom (7 items)
(88, 14,'Kolkata Chicken Biryani',    'Fragrant light biryani with golden potato & boiled egg.',        'Biryani',     339.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80'),
(89, 14,'Kosha Mangsho',              'Slow-braised Bengali mutton curry in caramelized onion gravy.',  'Main Course', 449.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&q=80'),
(90, 14,'Luchi & Aloor Dum (4 Pcs)',  'Puffed golden flatbreads paired with Bengali spiced potatoes.',  'Main Course', 199.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80'),
(91, 14,'Chingri Malai Curry',        'Tiger prawns cooked in creamy coconut-mustard gravy.',           'Main Course', 469.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&q=80'),
(92, 14,'Beguni & Mochar Chop',       'Crispy aubergine fritters & banana blossom croquettes.',         'Starters',    169.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80'),
(93, 14,'Mishti Doi Clay Pot',        'Traditional caramelized sweet yogurt set in terracotta.',        'Desserts',    119.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?w=600&q=80'),
(94, 14,'Aam Pora Shorbot',           'Roasted green mango cooler with black salt & mint.',             'Beverages',    99.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&q=80'),

-- Restaurants 15: Grill Masters BBQ (6 items)
(95, 15,'Crispy Chicken Smash Burger','Double-seared chicken patty, cheddar, pickles & house sauce.',   'Burgers',     279.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80'),
(96, 15,'Peri-Peri Paneer Burger',    'Char-grilled spicy paneer slab with slaw in brioche bun.',      'Burgers',     249.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600&q=80'),
(97, 15,'Smoky BBQ Chicken Wings',    '8 pieces glazed in hickory-smoked barbecue sauce.',              'Starters',    299.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=600&q=80'),
(98, 15,'Peri-Peri Loaded Fries',     'Crispy skin-on fries topped with cheese sauce & jalapenos.',     'Starters',    179.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&q=80'),
(99, 15,'Grilled Peri-Peri Half Chicken','Flame-grilled chicken served with herb rice & garlic dip.',   'Main Course', 419.00, FALSE, TRUE, 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80'),
(100,15,'Belgian Chocolate Shake',    'Thick dark chocolate milkshake topped with whipped cream.',      'Beverages',   189.00, TRUE,  TRUE, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600&q=80');

-- ----------------------------------------------------------------------------
-- 5. Orders (100 Realistic Orders across Users & Restaurants)
-- Totals are computed from Order_Items below for exact 100% consistency.
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Orders` (order_id, user_id, restaurant_id, order_status, total_amount, delivery_address, special_instructions, order_date) VALUES
(1,  1,  1, 'DELIVERED',        0, '12 MG Road, Indiranagar, Bengaluru',           'Less spicy please',        NOW() - INTERVAL 29 DAY),
(2,  2,  5, 'DELIVERED',        0, '45 Linking Road, Bandra West, Mumbai',         'Extra green chutney',      NOW() - INTERVAL 28 DAY),
(3,  3,  4, 'DELIVERED',        0, '78 Connaught Place, Block B, New Delhi',       'Ring bell once',           NOW() - INTERVAL 28 DAY),
(4,  4,  2, 'DELIVERED',        0, '23 Jubilee Hills, Road No 36, Hyderabad',      'Extra raita',              NOW() - INTERVAL 27 DAY),
(5,  5,  9, 'DELIVERED',        0, '90 Koregaon Park, Lane 7, Pune',               'Include oregano sachets',  NOW() - INTERVAL 27 DAY),
(6,  6,  3, 'DELIVERED',        0, '14 Anna Nagar East, 2nd Ave, Chennai',         'Hot sambar',               NOW() - INTERVAL 26 DAY),
(7,  7,  8, 'DELIVERED',        0, '56 Koramangala 4th Block, Bengaluru',          'No MSG',                   NOW() - INTERVAL 26 DAY),
(8,  8,  7, 'DELIVERED',        0, '88 Powai Lake View, Mumbai',                   'Leave at gate',            NOW() - INTERVAL 25 DAY),
(9,  9,  13,'DELIVERED',        0, '31 FC Road, Shivajinagar, Pune',               'Pack chutney separately',  NOW() - INTERVAL 25 DAY),
(10, 10, 3, 'DELIVERED',        0, '67 Besant Nagar, Chennai',                     'Less sugar in coffee',     NOW() - INTERVAL 24 DAY),
(11, 11, 4, 'DELIVERED',        0, '19 Hauz Khas Village, New Delhi',              'Well cooked',              NOW() - INTERVAL 24 DAY),
(12, 12, 2, 'DELIVERED',        0, '42 Banjara Hills, Hyderabad',                  'Call on arrival',          NOW() - INTERVAL 23 DAY),
(13, 13, 1, 'DELIVERED',        0, '73 Whitefield Main Road, Bengaluru',           'Extra butter naan',        NOW() - INTERVAL 23 DAY),
(14, 14, 14,'DELIVERED',        0, '15 Park Street, Kolkata',                      'No cutlery needed',        NOW() - INTERVAL 22 DAY),
(15, 15, 12,'DELIVERED',        0, '29 C-Scheme, Ashok Marg, Jaipur',              'Gift wrap mithai box',     NOW() - INTERVAL 22 DAY),
(16, 16, 6, 'DELIVERED',        0, '64 Sector 17 Plaza, Chandigarh',               'Extra white butter',       NOW() - INTERVAL 21 DAY),
(17, 17, 10,'DELIVERED',        0, '81 HSR Layout Sector 2, Bengaluru',            'Dressing on the side',     NOW() - INTERVAL 21 DAY),
(18, 18, 11,'DELIVERED',        0, '10 Gomti Nagar, Lucknow',                      'Serve hot',                NOW() - INTERVAL 20 DAY),
(19, 19, 15,'DELIVERED',        0, '37 Cyber Hub, DLF Phase 2, Gurugram',          'Extra peri-peri dip',      NOW() - INTERVAL 20 DAY),
(20, 20, 6, 'DELIVERED',        0, '52 Model Town Extension, Ludhiana',            'Sweet lassi chilled',      NOW() - INTERVAL 19 DAY),
(21, 21, 1, 'DELIVERED',        0, '28 Jayanagar 3rd Block, Bengaluru',            NULL,                       NOW() - INTERVAL 19 DAY),
(22, 22, 3, 'DELIVERED',        0, '94 Adyar, Gandhi Nagar, Chennai',              'Crispy dosa',              NOW() - INTERVAL 18 DAY),
(23, 23, 5, 'DELIVERED',        0, '18 Vijay Nagar Square, Indore',                'Extra pav',                NOW() - INTERVAL 18 DAY),
(24, 24, 15,'DELIVERED',        0, '71 Sector 62, Noida',                          'No onions in burger',      NOW() - INTERVAL 17 DAY),
(25, 25, 2, 'DELIVERED',        0, '33 Boring Road, Patna',                        'Medium spice',             NOW() - INTERVAL 17 DAY),
(26, 26, 8, 'DELIVERED',        0, '49 Malleswaram 8th Cross, Bengaluru',          'Chilli sauce packets',     NOW() - INTERVAL 16 DAY),
(27, 27, 11,'DELIVERED',        0, '62 Civil Lines, Prayagraj',                    NULL,                       NOW() - INTERVAL 16 DAY),
(28, 28, 14,'DELIVERED',        0, '85 Salt Lake Sector V, Kolkata',               'Extra mustard sauce',      NOW() - INTERVAL 15 DAY),
(29, 29, 12,'DELIVERED',        0, '11 Malviya Nagar, Jaipur',                     'Fresh batch please',       NOW() - INTERVAL 15 DAY),
(30, 30, 9, 'DELIVERED',        0, '44 Kothrud, Paud Road, Pune',                  'Cut into 8 slices',        NOW() - INTERVAL 14 DAY),
(31, 31, 7, 'DELIVERED',        0, '77 Andheri West, Mumbai',                      'Extra kokum sol kadhi',    NOW() - INTERVAL 14 DAY),
(32, 32, 10,'DELIVERED',        0, '25 Satellite Road, Ahmedabad',                 'No peanuts',               NOW() - INTERVAL 13 DAY),
(33, 33, 4, 'DELIVERED',        0, '58 Rajouri Garden, New Delhi',                 'Mint chutney extra',       NOW() - INTERVAL 13 DAY),
(34, 34, 13,'DELIVERED',        0, '91 Viman Nagar, Pune',                         'Hot chai flask',           NOW() - INTERVAL 12 DAY),
(35, 35, 6, 'DELIVERED',        0, '16 Sector 35-C, Chandigarh',                   NULL,                       NOW() - INTERVAL 12 DAY),
(36, 36, 5, 'DELIVERED',        0, '39 Dadar West, Mumbai',                        'Spicy garlic chutney',     NOW() - INTERVAL 11 DAY),
(37, 37, 11,'DELIVERED',        0, '83 Hazratganj, Lucknow',                       'Extra kewra aroma',        NOW() - INTERVAL 11 DAY),
(38, 38, 4, 'DELIVERED',        0, '21 Greater Kailash 1, New Delhi',              'Butter on naan',           NOW() - INTERVAL 10 DAY),
(39, 39, 3, 'DELIVERED',        0, '68 T Nagar, Chennai',                          'No garlic',                NOW() - INTERVAL 10 DAY),
(40, 40, 2, 'DELIVERED',        0, '47 Madhapur, Hyderabad',                       'Double masala',            NOW() - INTERVAL 9 DAY),
(41, 41, 1, 'DELIVERED',        0, '13 JP Nagar 7th Phase, Bengaluru',             NULL,                       NOW() - INTERVAL 9 DAY),
(42, 42, 14,'DELIVERED',        0, '76 Ballygunge Place, Kolkata',                 'Extra potato in biryani',  NOW() - INTERVAL 8 DAY),
(43, 43, 15,'DELIVERED',        0, '30 Golf Course Rd, Gurugram',                  'Extra cheese dip',         NOW() - INTERVAL 8 DAY),
(44, 44, 9, 'DELIVERED',        0, '55 Aundh, ITI Road, Pune',                     'Chilli flakes',            NOW() - INTERVAL 7 DAY),
(45, 45, 2, 'DELIVERED',        0, '89 Gachibowli, Hyderabad',                     'Leave at reception',       NOW() - INTERVAL 7 DAY),
(46, 46, 8, 'DELIVERED',        0, '24 Sector 18 Market, Noida',                   'Extra Schezwan dip',       NOW() - INTERVAL 6 DAY),
(47, 47, 4, 'DELIVERED',        0, '61 Vasant Kunj, New Delhi',                    NULL,                       NOW() - INTERVAL 6 DAY),
(48, 48, 7, 'DELIVERED',        0, '34 Lower Parel, Mumbai',                       'Medium spice',             NOW() - INTERVAL 5 DAY),
(49, 49, 3, 'DELIVERED',        0, '92 Mylapore, Chennai',                         'Pure ghee podi',           NOW() - INTERVAL 5 DAY),
(50, 50, 12,'DELIVERED',        0, '17 Navrangpura, Ahmedabad',                    'Warm gulab jamun',         NOW() - INTERVAL 4 DAY),
(51, 1,  8, 'DELIVERED',        0, '12 MG Road, Indiranagar, Bengaluru',           NULL,                       NOW() - INTERVAL 4 DAY),
(52, 2,  7, 'DELIVERED',        0, '45 Linking Road, Bandra West, Mumbai',         'Extra appam',              NOW() - INTERVAL 4 DAY),
(53, 3,  15,'DELIVERED',        0, '78 Connaught Place, New Delhi',                'Extra napkins',            NOW() - INTERVAL 3 DAY),
(54, 4,  10,'DELIVERED',        0, '23 Jubilee Hills, Hyderabad',                  'Fresh juice',              NOW() - INTERVAL 3 DAY),
(55, 5,  13,'DELIVERED',        0, '90 Koregaon Park, Pune',                       'Less ice in cold coffee',  NOW() - INTERVAL 3 DAY),
(56, 6,  2, 'DELIVERED',        0, '14 Anna Nagar East, Chennai',                  NULL,                       NOW() - INTERVAL 3 DAY),
(57, 7,  10,'DELIVERED',        0, '56 Koramangala 4th Block, Bengaluru',          'No croutons',              NOW() - INTERVAL 2 DAY),
(58, 8,  5, 'DELIVERED',        0, '88 Powai Lake View, Mumbai',                   'Extra sev',                NOW() - INTERVAL 2 DAY),
(59, 9,  9, 'DELIVERED',        0, '31 FC Road, Pune',                             'Thin crust',               NOW() - INTERVAL 2 DAY),
(60, 10, 12,'DELIVERED',        0, '67 Besant Nagar, Chennai',                     'Pack dry ice for kulfi',   NOW() - INTERVAL 2 DAY),
(61, 11, 6, 'DELIVERED',        0, '19 Hauz Khas Village, New Delhi',              NULL,                       NOW() - INTERVAL 2 DAY),
(62, 12, 11,'DELIVERED',        0, '42 Banjara Hills, Hyderabad',                  'Saffron garnish',          NOW() - INTERVAL 1 DAY),
(63, 13, 8, 'DELIVERED',        0, '73 Whitefield Main Road, Bengaluru',           'Extra momo chutney',       NOW() - INTERVAL 1 DAY),
(64, 14, 1, 'DELIVERED',        0, '15 Park Street, Kolkata',                      NULL,                       NOW() - INTERVAL 1 DAY),
(65, 15, 4, 'DELIVERED',        0, '29 C-Scheme, Jaipur',                          'Crispy naan',              NOW() - INTERVAL 1 DAY),
(66, 16, 15,'DELIVERED',        0, '64 Sector 17, Chandigarh',                     'Extra fries salt',         NOW() - INTERVAL 1 DAY),
(67, 17, 1, 'DELIVERED',        0, '81 HSR Layout, Bengaluru',                     NULL,                       NOW() - INTERVAL 22 HOUR),
(68, 18, 12,'DELIVERED',        0, '10 Gomti Nagar, Lucknow',                      'No silver leaf',           NOW() - INTERVAL 20 HOUR),
(69, 19, 4, 'DELIVERED',        0, '37 Cyber Hub, Gurugram',                       'Ring doorbell',            NOW() - INTERVAL 18 HOUR),
(70, 20, 13,'DELIVERED',        0, '52 Model Town, Ludhiana',                      'Extra masala in chai',     NOW() - INTERVAL 16 HOUR),
(71, 21, 10,'DELIVERED',        0, '28 Jayanagar 3rd Block, Bengaluru',            NULL,                       NOW() - INTERVAL 14 HOUR),
(72, 22, 14,'DELIVERED',        0, '94 Adyar, Chennai',                            'Pack gravy tight',         NOW() - INTERVAL 12 HOUR),
(73, 23, 6, 'DELIVERED',        0, '18 Vijay Nagar, Indore',                       NULL,                       NOW() - INTERVAL 11 HOUR),
(74, 24, 9, 'DELIVERED',        0, '71 Sector 62, Noida',                          'Extra cheese',             NOW() - INTERVAL 10 HOUR),
(75, 25, 11,'DELIVERED',        0, '33 Boring Road, Patna',                        NULL,                       NOW() - INTERVAL 9 HOUR),
(76, 26, 1, 'OUT_FOR_DELIVERY', 0, '49 Malleswaram, Bengaluru',                    'Call when at gate',        NOW() - INTERVAL 3 HOUR),
(77, 27, 4, 'OUT_FOR_DELIVERY', 0, '62 Civil Lines, Prayagraj',                    'Hot delivery',             NOW() - INTERVAL 2 HOUR),
(78, 28, 14,'OUT_FOR_DELIVERY', 0, '85 Salt Lake, Kolkata',                        NULL,                       NOW() - INTERVAL 2 HOUR),
(79, 29, 12,'OUT_FOR_DELIVERY', 0, '11 Malviya Nagar, Jaipur',                     'Handle carefully',         NOW() - INTERVAL 90 MINUTE),
(80, 30, 9, 'OUT_FOR_DELIVERY', 0, '44 Kothrud, Pune',                             'Extra oregano',            NOW() - INTERVAL 80 MINUTE),
(81, 31, 5, 'PREPARING',        0, '77 Andheri West, Mumbai',                      'Extra butter on pav',      NOW() - INTERVAL 60 MINUTE),
(82, 32, 10,'PREPARING',        0, '25 Satellite Road, Ahmedabad',                 'Fresh avocado',            NOW() - INTERVAL 55 MINUTE),
(83, 33, 6, 'PREPARING',        0, '58 Rajouri Garden, New Delhi',                 'No onion in chole',        NOW() - INTERVAL 50 MINUTE),
(84, 34, 13,'PREPARING',        0, '91 Viman Nagar, Pune',                         'Crispy samosa',            NOW() - INTERVAL 45 MINUTE),
(85, 35, 15,'PREPARING',        0, '16 Sector 35-C, Chandigarh',                   'Medium spice wings',       NOW() - INTERVAL 40 MINUTE),
(86, 36, 7, 'CONFIRMED',        0, '39 Dadar West, Mumbai',                        'Fresh appam',              NOW() - INTERVAL 35 MINUTE),
(87, 37, 11,'CONFIRMED',        0, '83 Hazratganj, Lucknow',                       NULL,                       NOW() - INTERVAL 30 MINUTE),
(88, 38, 2, 'CONFIRMED',        0, '21 Greater Kailash 1, New Delhi',              'Extra salan',              NOW() - INTERVAL 25 MINUTE),
(89, 39, 3, 'CONFIRMED',        0, '68 T Nagar, Chennai',                          'Hot filter coffee',        NOW() - INTERVAL 20 MINUTE),
(90, 40, 8, 'CONFIRMED',        0, '47 Madhapur, Hyderabad',                       'Chopsticks included',      NOW() - INTERVAL 18 MINUTE),
(91, 41, 1, 'PLACED',           0, '13 JP Nagar, Bengaluru',                       'Less oil',                 NOW() - INTERVAL 15 MINUTE),
(92, 42, 14,'PLACED',           0, '76 Ballygunge Place, Kolkata',                 NULL,                       NOW() - INTERVAL 12 MINUTE),
(93, 43, 15,'PLACED',           0, '30 Golf Course Rd, Gurugram',                  'Extra ketchup',            NOW() - INTERVAL 10 MINUTE),
(94, 44, 9, 'PLACED',           0, '55 Aundh, Pune',                               NULL,                       NOW() - INTERVAL 8 MINUTE),
(95, 45, 2, 'PLACED',           0, '89 Gachibowli, Hyderabad',                     'Leave at door',            NOW() - INTERVAL 5 MINUTE),
(96, 46, 8, 'CANCELLED',        0, '24 Sector 18, Noida',                          'Changed mind',             NOW() - INTERVAL 6 DAY),
(97, 47, 5, 'CANCELLED',        0, '61 Vasant Kunj, New Delhi',                    'Wrong address selected',   NOW() - INTERVAL 5 DAY),
(98, 48, 3, 'CANCELLED',        0, '34 Lower Parel, Mumbai',                       'Duplicate order',          NOW() - INTERVAL 3 DAY),
(99, 49, 10,'CANCELLED',        0, '92 Mylapore, Chennai',                         'Payments timeout',          NOW() - INTERVAL 2 DAY),
(100,50, 1, 'PLACED',           0, '17 Navrangpura, Ahmedabad',                    'No cutlery',               NOW() - INTERVAL 2 MINUTE);

-- ----------------------------------------------------------------------------
-- 6. Order_Items (185 Interconnected Order Items across all 100 Orders)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Order_Items` (order_item_id, order_id, food_id, quantity, item_price, subtotal) VALUES
(1,  1,  1,  1, 299.00, 299.00), (2,  1,  3,  2,  79.00, 158.00), (3,  1,  7,  1, 129.00, 129.00),
(4,  2,  29, 2, 179.00, 358.00), (5,  2,  30, 1,  99.00,  99.00),
(6,  3,  22, 1, 369.00, 369.00), (7,  3,  27, 2,  69.00, 138.00),
(8,  4,  8,  2, 349.00, 698.00), (9,  4,  12, 1, 159.00, 159.00),
(10, 5,  57, 1, 399.00, 399.00), (11, 5,  60, 1, 179.00, 179.00),
(12, 6,  15, 2, 169.00, 338.00), (13, 6,  19, 2,  79.00, 158.00),
(14, 7,  50, 1, 219.00, 219.00), (15, 7,  51, 1, 249.00, 249.00),
(16, 8,  43, 1, 429.00, 429.00), (17, 8,  47, 2,  99.00, 198.00),
(18, 9,  82, 1, 149.00, 149.00), (19, 9,  84, 2,  79.00, 158.00),
(20, 10, 16, 1, 139.00, 139.00), (21, 10, 17, 1, 119.00, 119.00),
(22, 11, 23, 1, 389.00, 389.00), (23, 11, 25, 2, 149.00, 298.00),
(24, 12, 9,  1, 449.00, 449.00), (25, 12, 11, 1, 289.00, 289.00),
(26, 13, 5,  1, 349.00, 349.00), (27, 13, 3,  3,  79.00, 237.00),
(28, 14, 89, 1, 449.00, 449.00), (29, 14, 90, 1, 199.00, 199.00), (30, 14, 93, 2, 119.00, 238.00),
(31, 15, 76, 2, 129.00, 258.00), (32, 15, 78, 1, 349.00, 349.00),
(33, 16, 36, 1, 269.00, 269.00), (34, 16, 40, 2, 109.00, 218.00),
(35, 17, 64, 1, 319.00, 319.00), (36, 17, 67, 1, 149.00, 149.00),
(37, 18, 70, 1, 399.00, 399.00), (38, 18, 71, 1, 439.00, 439.00),
(39, 19, 95, 2, 279.00, 558.00), (40, 19, 98, 1, 179.00, 179.00),
(41, 20, 37, 2, 199.00, 398.00), (42, 20, 40, 1, 109.00, 109.00),
(43, 21, 2,  1, 259.00, 259.00), (44, 21, 6,  1, 179.00, 179.00),
(45, 22, 15, 1, 169.00, 169.00), (46, 22, 18, 1, 159.00, 159.00),
(47, 23, 31, 2, 129.00, 258.00), (48, 23, 32, 1, 189.00, 189.00),
(49, 24, 96, 1, 249.00, 249.00), (50, 24, 100,1, 189.00, 189.00),
(51, 25, 10, 2, 279.00, 558.00), (52, 25, 14, 2,  89.00, 178.00),
(53, 26, 52, 1, 269.00, 269.00), (54, 26, 55, 2, 189.00, 378.00),
(55, 27, 73, 1, 309.00, 309.00), (56, 27, 74, 2,  99.00, 198.00), (57, 27, 75, 1, 189.00, 189.00),
(58, 28, 88, 1, 339.00, 339.00), (59, 28, 92, 1, 169.00, 169.00),
(60, 29, 77, 2, 169.00, 338.00), (61, 29, 81, 1, 129.00, 129.00),
(62, 30, 58, 1, 329.00, 329.00), (63, 30, 61, 1, 289.00, 289.00),
(64, 31, 44, 1, 449.00, 449.00), (65, 31, 45, 1, 229.00, 229.00),
(66, 32, 65, 1, 349.00, 349.00), (67, 32, 68, 1, 249.00, 249.00),
(68, 33, 24, 1, 329.00, 329.00), (69, 33, 26, 1, 289.00, 289.00),
(70, 34, 82, 1, 149.00, 149.00), (71, 34, 83, 2,  89.00, 178.00), (72, 34, 87, 1, 139.00, 139.00),
(73, 35, 38, 1, 339.00, 339.00), (74, 35, 41, 2, 129.00, 258.00),
(75, 36, 29, 1, 179.00, 179.00), (76, 36, 33, 1, 169.00, 169.00),
(77, 37, 71, 2, 439.00, 878.00), (78, 37, 75, 1, 189.00, 189.00),
(79, 38, 22, 1, 369.00, 369.00), (80, 38, 28, 2, 139.00, 278.00),
(81, 39, 20, 1, 149.00, 149.00), (82, 39, 21, 1, 319.00, 319.00),
(83, 40, 8,  1, 349.00, 349.00), (84, 40, 13, 1, 249.00, 249.00),
(85, 41, 4,  1, 279.00, 279.00), (86, 41, 1,  1, 299.00, 299.00),
(87, 42, 91, 1, 469.00, 469.00), (88, 42, 94, 2,  99.00, 198.00),
(89, 43, 97, 1, 299.00, 299.00), (90, 43, 99, 1, 419.00, 419.00),
(91, 44, 59, 1, 449.00, 449.00), (92, 44, 62, 1, 219.00, 219.00), (93, 44, 63, 2, 129.00, 258.00),
(94, 45, 9,  2, 449.00, 898.00),
(95, 46, 53, 1, 229.00, 229.00), (96, 46, 54, 1, 199.00, 199.00),
(97, 47, 23, 1, 389.00, 389.00), (98, 47, 27, 3,  69.00, 207.00),
(99, 48, 46, 1, 349.00, 349.00), (100,48, 49, 1, 159.00, 159.00),
(101,49, 16, 2, 139.00, 278.00), (102,49, 19, 1,  79.00,  79.00),
(103,50, 76, 1, 129.00, 129.00), (104,50, 79, 2, 139.00, 278.00),
(105,51, 50, 2, 219.00, 438.00), (106,51, 56, 1, 119.00, 119.00),
(107,52, 43, 1, 429.00, 429.00), (108,52, 45, 1, 229.00, 229.00),
(109,53, 95, 1, 279.00, 279.00), (110,53, 97, 1, 299.00, 299.00),
(111,54, 66, 1, 269.00, 269.00), (112,54, 67, 2, 149.00, 298.00),
(113,55, 86, 2, 159.00, 318.00), (114,55, 85, 1, 119.00, 119.00),
(115,56, 8,  1, 349.00, 349.00), (116,56, 12, 2, 159.00, 318.00),
(117,57, 64, 1, 319.00, 319.00), (118,57, 69, 1, 229.00, 229.00),
(119,58, 34, 2,  99.00, 198.00), (120,58, 35, 1, 119.00, 119.00),
(121,59, 57, 1, 399.00, 399.00), (122,59, 63, 1, 129.00, 129.00),
(123,60, 79, 1, 139.00, 139.00), (124,60, 80, 2, 149.00, 298.00),
(125,61, 39, 2, 189.00, 378.00), (126,61, 42, 1, 169.00, 169.00),
(127,62, 72, 1, 389.00, 389.00), (128,62, 74, 2,  99.00, 198.00),
(129,63, 55, 2, 189.00, 378.00), (130,63, 51, 1, 249.00, 249.00),
(131,64, 5,  1, 349.00, 349.00), (132,64, 6,  1, 179.00, 179.00),
(133,65, 22, 1, 369.00, 369.00), (134,65, 25, 1, 149.00, 149.00),
(135,66, 98, 2, 179.00, 358.00), (136,66, 100,1, 189.00, 189.00),
(137,67, 1,  1, 299.00, 299.00), (138,67, 3,  2,  79.00, 158.00),
(139,68, 78, 1, 349.00, 349.00), (140,68, 77, 1, 169.00, 169.00),
(141,69, 24, 1, 329.00, 329.00), (142,69, 27, 2,  69.00, 138.00),
(143,70, 82, 1, 149.00, 149.00), (144,70, 84, 1,  79.00,  79.00),
(145,71, 65, 1, 349.00, 349.00), (146,71, 67, 1, 149.00, 149.00),
(147,72, 89, 1, 449.00, 449.00), (148,72, 93, 1, 119.00, 119.00),
(149,73, 37, 2, 199.00, 398.00), (150,73, 40, 1, 109.00, 109.00),
(151,74, 58, 1, 329.00, 329.00), (152,74, 60, 1, 179.00, 179.00),
(153,75, 70, 1, 399.00, 399.00), (154,75, 75, 1, 189.00, 189.00),
(155,76, 2,  1, 259.00, 259.00), (156,76, 3,  2,  79.00, 158.00),
(157,77, 22, 1, 369.00, 369.00), (158,77, 26, 1, 289.00, 289.00),
(159,78, 88, 2, 339.00, 678.00),
(160,79, 76, 2, 129.00, 258.00), (161,79, 81, 1, 129.00, 129.00),
(162,80, 57, 1, 399.00, 399.00), (163,80, 61, 1, 289.00, 289.00),
(164,81, 29, 2, 179.00, 358.00), (165,81, 30, 2,  99.00, 198.00),
(166,82, 64, 1, 319.00, 319.00), (167,82, 66, 1, 269.00, 269.00),
(168,83, 36, 1, 269.00, 269.00), (169,83, 40, 1, 109.00, 109.00),
(170,84, 83, 2,  89.00, 178.00), (171,84, 86, 1, 159.00, 159.00),
(172,85, 97, 1, 299.00, 299.00), (173,85, 95, 1, 279.00, 279.00),
(174,86, 45, 2, 229.00, 458.00), (175,86, 47, 1,  99.00,  99.00),
(176,87, 71, 1, 439.00, 439.00),
(177,88, 8,  2, 349.00, 698.00), (178,88, 11, 1, 289.00, 289.00),
(179,89, 15, 1, 169.00, 169.00), (180,89, 19, 2,  79.00, 158.00),
(181,90, 50, 1, 219.00, 219.00), (182,90, 53, 1, 229.00, 229.00),
(183,91, 1,  1, 299.00, 299.00), (184,91, 7,  1, 129.00, 129.00),
(185,92, 90, 2, 199.00, 398.00),
(186,93, 96, 1, 249.00, 249.00), (187,93, 98, 1, 179.00, 179.00),
(188,94, 59, 1, 449.00, 449.00),
(189,95, 10, 1, 279.00, 279.00), (190,95, 14, 1,  89.00,  89.00),
(191,96, 52, 1, 269.00, 269.00),
(192,97, 32, 1, 189.00, 189.00),
(193,98, 17, 2, 119.00, 238.00),
(194,99, 68, 1, 249.00, 249.00),
(195,100,4,  1, 279.00, 279.00), (196,100,5,  1, 349.00, 349.00);

-- Recompute exact order totals from Order_Items so every order matches sum(subtotal)
UPDATE `Orders` o
SET o.total_amount = (
    SELECT COALESCE(SUM(oi.subtotal), 0.00)
    FROM `Order_Items` oi
    WHERE oi.order_id = o.order_id
);

-- ----------------------------------------------------------------------------
-- 7. Payments (100 Corresponding Payments Records)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Payments` (payment_id, order_id, payment_method, payment_status, amount, transaction_ref, payment_date)
SELECT
    o.order_id AS payment_id,
    o.order_id,
    CASE (o.order_id % 5)
        WHEN 0 THEN 'UPI'
        WHEN 1 THEN 'CARD'
        WHEN 2 THEN 'NET_BANKING'
        WHEN 3 THEN 'WALLET'
        ELSE 'COD'
    END AS payment_method,
    CASE
        WHEN o.order_status = 'CANCELLED' THEN 'REFUNDED'
        WHEN o.order_status = 'PLACED' AND (o.order_id % 5) = 4 THEN 'PENDING'
        ELSE 'SUCCESS'
    END AS payment_status,
    o.total_amount AS amount,
    CONCAT('TXN-FE-', LPAD(o.order_id, 6, '0')) AS transaction_ref,
    o.order_date AS payment_date
FROM `Orders` o;
