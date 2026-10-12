#!/usr/bin/env python3
"""
Project BHARAT-FLOW: ONDC Pan-India Retail Inventory & Customer Lifecycle Benchmark Generator
Generates clean, realistic, grounded datasets for Indian retail supply chain analytics.
"""

import os
import random
import datetime
import numpy as np
import pandas as pd
import sqlite3

# Set deterministic seed
np.random.seed(42)
random.seed(42)

# Ensure output directories exist
os.makedirs("data", exist_ok=True)

print("Step 1: Generating Suppliers...")
suppliers_data = [
    ("SUP-001", "ITC Limited (Foods Division)", "Kolkata", "West Bengal", "East", 0.94, 4, 1.2),
    ("SUP-002", "Hindustan Unilever Limited (HUL)", "Mumbai", "Maharashtra", "West", 0.96, 3, 0.8),
    ("SUP-003", "Dabur India Limited", "Ghaziabad", "Uttar Pradesh", "North", 0.91, 5, 1.5),
    ("SUP-004", "Gujarat Coop Milk Marketing Fed (Amul)", "Anand", "Gujarat", "West", 0.98, 2, 0.5),
    ("SUP-005", "Bureau of Pharma PSUs of India (BPPI / PMBJP)", "New Delhi", "Delhi", "North", 0.88, 7, 2.4),
    ("SUP-006", "Tata Consumer Products Ltd", "Bengaluru", "Karnataka", "South", 0.95, 4, 1.1),
    ("SUP-007", "Adani Wilmar Limited", "Ahmedabad", "Gujarat", "West", 0.92, 5, 1.4),
    ("SUP-008", "Mother Dairy Fruit & Vegetable Pvt Ltd", "Noida", "Uttar Pradesh", "North", 0.97, 2, 0.6),
    ("SUP-009", "Karnataka Milk Federation (Nandini)", "Bengaluru", "Karnataka", "South", 0.96, 2, 0.5),
    ("SUP-010", "Haldiram Snacks Pvt Ltd", "Nagpur", "Maharashtra", "West", 0.93, 4, 1.0),
    ("SUP-011", "Britannia Industries Ltd", "Bengaluru", "Karnataka", "South", 0.95, 3, 0.9),
    ("SUP-012", "Mankind Pharma Limited", "New Delhi", "Delhi", "North", 0.90, 6, 1.8),
]
df_suppliers = pd.DataFrame(suppliers_data, columns=[
    "supplier_id", "supplier_name", "city", "state", "zone", "reliability_score", "contract_lead_time_days", "lead_time_std_dev"
])
df_suppliers.to_csv("data/suppliers.csv", index=False)

print("Step 2: Generating Fulfillment Hubs...")
hubs_data = [
    ("HUB-DEL-CWH", "Central Warehouse North (NCR)", "Central Warehouse", "Gurugram", "Haryana", "Tier-1", "North", 50000, 42.5),
    ("HUB-MUM-CWH", "Central Warehouse West (BOM)", "Central Warehouse", "Bhiwandi", "Maharashtra", "Tier-1", "West", 55000, 48.0),
    ("HUB-BLR-CWH", "Central Warehouse South (BLR)", "Central Warehouse", "Hosur", "Karnataka", "Tier-1", "South", 48000, 44.0),
    ("HUB-KOL-RDH", "Regional Distribution Hub East", "Regional Hub", "Kolkata", "West Bengal", "Tier-1", "East", 25000, 32.0),
    ("HUB-LKO-RDH", "Regional Distribution Hub Awadh", "Regional Hub", "Lucknow", "Uttar Pradesh", "Tier-2", "North", 20000, 26.5),
    ("HUB-JAI-RDH", "Regional Distribution Hub Marwar", "Regional Hub", "Jaipur", "Rajasthan", "Tier-2", "North", 18000, 24.0),
    ("HUB-IXJ-RDH", "Regional Distribution Hub Northern Front", "Regional Hub", "Jammu", "Jammu & Kashmir", "Tier-3", "North", 12000, 19.5),
    ("HUB-PAT-RDH", "Regional Distribution Hub Magadh", "Regional Hub", "Patna", "Bihar", "Tier-2", "East", 16000, 22.0),
    ("HUB-GAU-RDH", "Regional Distribution Hub North-East", "Regional Hub", "Guwahati", "Assam", "Tier-2", "North-East", 15000, 25.0),
    ("HUB-BHO-RDH", "Regional Distribution Hub Malwa", "Regional Hub", "Bhopal", "Madhya Pradesh", "Tier-2", "Central", 18000, 21.0),
    ("HUB-COI-RDH", "Regional Distribution Hub Kongu", "Regional Hub", "Coimbatore", "Tamil Nadu", "Tier-2", "South", 16000, 23.5),
    ("HUB-DEL-MFC", "Urban Dark Store ONDC South Delhi", "Micro-Fulfillment Center", "New Delhi", "Delhi", "Tier-1", "North", 6000, 65.0),
    ("HUB-MUM-MFC", "Urban Dark Store ONDC Andheri", "Micro-Fulfillment Center", "Mumbai", "Maharashtra", "Tier-1", "West", 5500, 78.0),
    ("HUB-BLR-MFC", "Urban Dark Store ONDC Koramangala", "Micro-Fulfillment Center", "Bengaluru", "Karnataka", "Tier-1", "South", 6500, 62.0),
    ("HUB-IXJ-KIR", "Hyperlocal Kirana SNP Jammu Tawi", "Kirana Network Participant", "Jammu", "Jammu & Kashmir", "Tier-3", "North", 1500, 28.0),
    ("HUB-DAR-KIR", "Hyperlocal Kirana SNP Darbhanga Bazaar", "Kirana Network Participant", "Darbhanga", "Bihar", "Tier-3", "East", 1400, 18.0),
    ("HUB-WAR-KIR", "Hyperlocal Kirana SNP Warangal Town", "Kirana Network Participant", "Warangal", "Telangana", "Tier-3", "South", 1600, 20.0),
]
df_hubs = pd.DataFrame(hubs_data, columns=[
    "hub_id", "hub_name", "hub_type", "city", "state", "tier", "zone", "storage_capacity_sqft", "operating_cost_per_sqft_inr"
])
df_hubs.to_csv("data/fulfillment_hubs.csv", index=False)

print("Step 3: Generating Product Catalog (SKU Master)...")
products_data = [
    # Packaged Food & Staples
    ("SKU-STP-001", "Aashirvaad Shudh Chakki Atta 10kg", "Packaged Food & Staples", "Atta & Flours", 410.0, 485.0, 0.18, 250.0, 50, 120, False, "SUP-001"),
    ("SKU-STP-002", "Fortune Sunlite Refined Sunflower Oil 1L", "Packaged Food & Staples", "Edible Oils", 125.0, 155.0, 0.18, 180.0, 40, 270, False, "SUP-007"),
    ("SKU-STP-003", "Tata Salt Vacuum Evaporated Iodized 1kg", "Packaged Food & Staples", "Spices & Salt", 21.0, 28.0, 0.15, 120.0, 100, 720, False, "SUP-006"),
    ("SKU-STP-004", "India Gate Basmati Rice Rozzana 5kg", "Packaged Food & Staples", "Rice & Grains", 360.0, 445.0, 0.18, 220.0, 30, 365, False, "SUP-001"),
    ("SKU-STP-005", "Maggi 2-Minute Masala Noodles 280g (Pack of 4)", "Packaged Food & Staples", "Instant Noodles", 50.0, 60.0, 0.18, 140.0, 60, 270, False, "SUP-001"),
    ("SKU-STP-006", "Catch Turmeric Powder 500g", "Packaged Food & Staples", "Spices & Salt", 110.0, 145.0, 0.16, 110.0, 50, 365, False, "SUP-003"),
    ("SKU-STP-007", "Organic Tattva Unpolished Toor Dal 1kg", "Packaged Food & Staples", "Pulses & Dals", 145.0, 185.0, 0.18, 150.0, 40, 240, False, "SUP-001"),

    # Essential Pharma & Jan Aushadhi OTC
    ("SKU-PHM-001", "PMBJP Jan Aushadhi Paracetamol 650mg (10 Tabs)", "Essential Pharma & OTC", "Antipyretics", 6.5, 12.0, 0.22, 90.0, 200, 730, False, "SUP-005"),
    ("SKU-PHM-002", "PMBJP Jan Aushadhi Metformin 500mg (10 Tabs)", "Essential Pharma & OTC", "Antidiabetic", 8.0, 16.0, 0.22, 95.0, 200, 730, False, "SUP-005"),
    ("SKU-PHM-003", "Electral WHO-Formula ORS Powder 21.8g Sachet", "Essential Pharma & OTC", "Rehydration", 16.0, 22.5, 0.20, 80.0, 150, 540, False, "SUP-012"),
    ("SKU-PHM-004", "PMBJP Jan Aushadhi Cetirizine 10mg (10 Tabs)", "Essential Pharma & OTC", "Antiallergic", 4.5, 9.0, 0.22, 85.0, 200, 730, False, "SUP-005"),
    ("SKU-PHM-005", "Dettol Antiseptic Liquid 250ml", "Essential Pharma & OTC", "First Aid", 120.0, 152.0, 0.18, 130.0, 50, 1095, False, "SUP-002"),
    ("SKU-PHM-006", "PMBJP Digital Flexible Thermometer", "Essential Pharma & OTC", "Medical Devices", 95.0, 150.0, 0.20, 160.0, 30, 1825, False, "SUP-005"),
    ("SKU-PHM-007", "Volini Joint & Muscle Pain Relief Gel 50g", "Essential Pharma & OTC", "Pain Relief", 115.0, 145.0, 0.20, 120.0, 40, 730, False, "SUP-012"),

    # Personal & Home Care
    ("SKU-HPC-001", "Surf Excel Easy Wash Detergent Powder 1kg", "Personal & Home Care", "Laundry Care", 118.0, 145.0, 0.16, 180.0, 60, 730, False, "SUP-002"),
    ("SKU-HPC-002", "Vim Dishwash Gel Lemon 500ml", "Personal & Home Care", "Dishwashing", 88.0, 115.0, 0.16, 140.0, 50, 730, False, "SUP-002"),
    ("SKU-HPC-003", "Lifebuoy Total Germ Protection Soap 125g (Pack of 4)", "Personal & Home Care", "Soaps & Body Wash", 110.0, 140.0, 0.16, 150.0, 50, 730, False, "SUP-002"),
    ("SKU-HPC-004", "Dabur Red Ayurvedic Toothpaste 300g", "Personal & Home Care", "Oral Care", 112.0, 142.0, 0.17, 130.0, 50, 540, False, "SUP-003"),
    ("SKU-HPC-005", "Parachute 100% Pure Coconut Oil 500ml", "Personal & Home Care", "Hair Care", 155.0, 195.0, 0.16, 160.0, 40, 540, False, "SUP-003"),
    ("SKU-HPC-006", "Lizol Disinfectant Floor Cleaner Citrus 1L", "Personal & Home Care", "Surface Cleaners", 168.0, 215.0, 0.16, 170.0, 30, 730, False, "SUP-002"),
    ("SKU-HPC-007", "Head & Shoulders Anti-Dandruff Shampoo 340ml", "Personal & Home Care", "Hair Care", 240.0, 310.0, 0.18, 180.0, 30, 730, False, "SUP-002"),

    # Dairy & Perishables
    ("SKU-PER-001", "Amul Taaza Homogenised Toned Milk 1L Tetra", "Dairy & Perishables", "Milk", 60.0, 72.0, 0.25, 120.0, 80, 90, True, "SUP-004"),
    ("SKU-PER-002", "Mother Dairy Classic Malai Paneer 200g", "Dairy & Perishables", "Dairy Essentials", 82.0, 98.0, 0.28, 110.0, 60, 30, True, "SUP-008"),
    ("SKU-PER-003", "Nandini Fresh Thick Curd 500g Pouch", "Dairy & Perishables", "Dairy Essentials", 28.0, 35.0, 0.28, 100.0, 80, 15, True, "SUP-009"),
    ("SKU-PER-004", "Epigamia Natural Greek Yogurt 90g Cup", "Dairy & Perishables", "Specialty Dairy", 42.0, 55.0, 0.30, 120.0, 50, 25, True, "SUP-004"),
    ("SKU-PER-005", "Farm Fresh Hybrid Salad Tomatoes 1kg", "Dairy & Perishables", "Fresh Vegetables", 28.0, 42.0, 0.35, 90.0, 100, 7, True, "SUP-008"),
    ("SKU-PER-006", "Fresh Nashik Grade-A Red Onions 2kg", "Dairy & Perishables", "Fresh Vegetables", 52.0, 74.0, 0.32, 100.0, 80, 21, True, "SUP-008"),
    ("SKU-PER-007", "Farm Fresh Pahadi Potatoes 2kg Net Bag", "Dairy & Perishables", "Fresh Vegetables", 44.0, 62.0, 0.30, 90.0, 80, 30, True, "SUP-008"),

    # Beverages & Snacks
    ("SKU-SNK-001", "Tata Tea Premium Desh Ki Chai 500g", "Beverages & Snacks", "Tea & Infusions", 195.0, 250.0, 0.16, 170.0, 50, 365, False, "SUP-006"),
    ("SKU-SNK-002", "Nescafe Classic 100% Pure Instant Coffee 50g", "Beverages & Snacks", "Coffee", 145.0, 185.0, 0.18, 150.0, 40, 540, False, "SUP-001"),
    ("SKU-SNK-003", "Haldirams Nagpur Aloo Bhujia Namkeen 400g", "Beverages & Snacks", "Namkeen & Snacks", 92.0, 120.0, 0.18, 140.0, 60, 180, False, "SUP-010"),
    ("SKU-SNK-004", "Britannia Good Day Butter Cookies 200g", "Beverages & Snacks", "Biscuits & Cookies", 36.0, 45.0, 0.18, 110.0, 80, 180, False, "SUP-011"),
    ("SKU-SNK-005", "Real Fruit Power Mixed Fruit Juice 1L", "Beverages & Snacks", "Juices & Drinks", 98.0, 130.0, 0.20, 150.0, 50, 270, False, "SUP-003"),
    ("SKU-SNK-006", "Paper Boat Aamras Alphonso Mango 250ml", "Beverages & Snacks", "Juices & Drinks", 28.0, 38.0, 0.20, 120.0, 60, 180, False, "SUP-006"),
    ("SKU-SNK-007", "Cadbury Bournvita Chocolate Health Drink 500g", "Beverages & Snacks", "Health Drinks", 195.0, 245.0, 0.16, 170.0, 40, 365, False, "SUP-001"),
]
df_products = pd.DataFrame(products_data, columns=[
    "product_id", "product_name", "category", "sub_category", "unit_cost_inr", "mrp_inr",
    "holding_cost_rate_annual", "ordering_cost_inr", "min_order_qty", "shelf_life_days", "is_perishable", "primary_supplier_id"
])
df_products.to_csv("data/products.csv", index=False)

print("Step 4: Generating Customers Master...")
first_names = ["Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan", "Krishna", "Ishaan",
               "Ananya", "Diya", "Saanvi", "Aadhya", "Pari", "Isha", "Navya", "Riya", "Myra", "Sneha",
               "Rahul", "Rohan", "Pooja", "Priya", "Amit", "Neha", "Vikram", "Sunita", "Deepak", "Kavita",
               "Rajesh", "Suresh", "Meena", "Geeta", "Manoj", "Sanjay", "Anil", "Sunil", "Rekha", "Anita"]
last_names = ["Sharma", "Verma", "Gupta", "Malhotra", "Bhatia", "Iyer", "Nair", "Patel", "Shah", "Mehta",
              "Reddy", "Rao", "Choudhury", "Das", "Banerjee", "Chatterjee", "Mishra", "Pandey", "Singh", "Yadav",
              "Joshi", "Kulkarni", "Deshmukh", "Patil", "Pillai", "Menon", "Kumar", "Agrawal", "Bansal", "Garg"]

cities_tier_zone = [
    ("New Delhi", "Delhi", "Tier-1", "North"),
    ("Mumbai", "Maharashtra", "Tier-1", "West"),
    ("Bengaluru", "Karnataka", "Tier-1", "South"),
    ("Kolkata", "West Bengal", "Tier-1", "East"),
    ("Lucknow", "Uttar Pradesh", "Tier-2", "North"),
    ("Jaipur", "Rajasthan", "Tier-2", "North"),
    ("Patna", "Bihar", "Tier-2", "East"),
    ("Bhopal", "Madhya Pradesh", "Tier-2", "Central"),
    ("Coimbatore", "Tamil Nadu", "Tier-2", "South"),
    ("Guwahati", "Assam", "Tier-2", "North-East"),
    ("Jammu", "Jammu & Kashmir", "Tier-3", "North"),
    ("Darbhanga", "Bihar", "Tier-3", "East"),
    ("Warangal", "Telangana", "Tier-3", "South"),
    ("Udupi", "Karnataka", "Tier-3", "South"),
    ("Silchar", "Assam", "Tier-3", "North-East")
]

customer_types = ["Retail Consumer", "Micro-Enterprise / Kirana Reseller", "Healthcare Clinic / Dispensary"]
cust_type_weights = [0.85, 0.10, 0.05]
payment_modes = ["UPI", "RuPay Debit", "NetBanking", "Cash on Delivery (COD)"]
payment_weights = [0.65, 0.15, 0.08, 0.12]
buyer_apps = ["ONDC Buyer App - Paytm", "ONDC Buyer App - Magicpin", "ONDC Buyer App - Mystore", "Direct Hyperlocal Web"]
buyer_app_weights = [0.45, 0.30, 0.15, 0.10]

customers_list = []
start_date = datetime.date(2024, 10, 1)
end_date = datetime.date(2025, 9, 30)
days_range = (end_date - start_date).days

for i in range(1, 1201):
    cid = f"CUST-{i:04d}"
    cname = f"{random.choice(first_names)} {random.choice(last_names)}"
    city_info = random.choice(cities_tier_zone)
    ctype = np.random.choice(customer_types, p=cust_type_weights)
    pmode = np.random.choice(payment_modes, p=payment_weights)
    app = np.random.choice(buyer_apps, p=buyer_app_weights)
    
    # Registration date
    reg_days = random.randint(0, days_range)
    reg_date = start_date + datetime.timedelta(days=reg_days)
    
    customers_list.append((
        cid, cname, city_info[0], city_info[1], city_info[2], city_info[3],
        reg_date.isoformat(), ctype, pmode, app
    ))

df_customers = pd.DataFrame(customers_list, columns=[
    "customer_id", "customer_name", "city", "state", "tier", "zone",
    "signup_date", "customer_type", "preferred_payment_mode", "buyer_app_channel"
])
df_customers.to_csv("data/customers.csv", index=False)

print("Step 5: Generating Inventory Snapshots across Hubs...")
inventory_list = []
inv_id_counter = 1
for _, hub in df_hubs.iterrows():
    hid = hub["hub_id"]
    tier = hub["tier"]
    htype = hub["hub_type"]
    
    for _, prod in df_products.iterrows():
        pid = prod["product_id"]
        unit_cost = prod["unit_cost_inr"]
        holding_rate = prod["holding_cost_rate_annual"]
        is_perish = prod["is_perishable"]
        
        # Scaling capacity and demand based on hub type
        if htype == "Central Warehouse":
            base_capacity = 4000 if not is_perish else 800
            current_stock = int(np.random.normal(2600, 400)) if not is_perish else int(np.random.normal(550, 80))
            safety_stock = int(np.random.normal(500, 60)) if not is_perish else int(np.random.normal(150, 20))
            reorder_pt = int(safety_stock * 2.2)
            stockouts = random.choices([0, 1, 2], weights=[0.85, 0.12, 0.03])[0]
        elif htype == "Regional Hub":
            base_capacity = 1800 if not is_perish else 400
            current_stock = int(np.random.normal(1100, 250)) if not is_perish else int(np.random.normal(260, 50))
            safety_stock = int(np.random.normal(280, 40)) if not is_perish else int(np.random.normal(90, 15))
            reorder_pt = int(safety_stock * 2.1)
            # Tier-3 hubs have higher stockout vulnerability
            if tier == "Tier-3":
                stockouts = random.choices([0, 1, 2, 3, 4], weights=[0.55, 0.25, 0.12, 0.05, 0.03])[0]
                current_stock = max(20, current_stock - 250)
            else:
                stockouts = random.choices([0, 1, 2, 3], weights=[0.75, 0.18, 0.05, 0.02])[0]
        elif htype == "Micro-Fulfillment Center":
            base_capacity = 600 if not is_perish else 250
            current_stock = int(np.random.normal(380, 80)) if not is_perish else int(np.random.normal(160, 30))
            safety_stock = int(np.random.normal(120, 20)) if not is_perish else int(np.random.normal(60, 10))
            reorder_pt = int(safety_stock * 2.0)
            stockouts = random.choices([0, 1, 2, 3], weights=[0.70, 0.20, 0.07, 0.03])[0]
        else: # Kirana Network Participant
            base_capacity = 150 if not is_perish else 60
            current_stock = int(np.random.normal(85, 25)) if not is_perish else int(np.random.normal(35, 10))
            safety_stock = int(np.random.normal(30, 8)) if not is_perish else int(np.random.normal(15, 5))
            reorder_pt = int(safety_stock * 1.8)
            stockouts = random.choices([0, 1, 2, 3, 5], weights=[0.50, 0.25, 0.15, 0.07, 0.03])[0]
            
        current_stock = max(5, current_stock)
        safety_stock = max(5, safety_stock)
        reorder_pt = max(safety_stock + 10, reorder_pt)
        max_cap = max(current_stock + 50, base_capacity)
        
        unit_carrying_cost = round(unit_cost * holding_rate, 2)
        last_rep_days = random.randint(1, 45)
        last_rep = (datetime.date(2026, 9, 30) - datetime.timedelta(days=last_rep_days)).isoformat()
        
        inventory_list.append((
            f"INV-{inv_id_counter:05d}", hid, pid, current_stock, safety_stock,
            reorder_pt, max_cap, stockouts, last_rep, unit_carrying_cost
        ))
        inv_id_counter += 1

df_inventory = pd.DataFrame(inventory_list, columns=[
    "inventory_id", "hub_id", "product_id", "current_stock_units", "safety_stock_units",
    "reorder_point_units", "max_capacity_units", "stockout_events_l90d", "last_replenished_date",
    "unit_carrying_cost_annual_inr"
])
df_inventory.to_csv("data/inventory.csv", index=False)

print("Step 6: Generating Order Transactions & Line Items...")
# Generate 8,000 orders across 2025-10-01 to 2026-09-30
order_start = datetime.date(2025, 10, 1)
order_end = datetime.date(2026, 9, 30)
order_days_span = (order_end - order_start).days

# Build map of city/zone to hubs
hub_zone_map = df_hubs.groupby("zone")["hub_id"].apply(list).to_dict()
all_hub_ids = df_hubs["hub_id"].tolist()

orders_list = []
order_items_list = []
item_counter = 1

# Customer activity profile
# Assign each customer an activity tier (Frequent, Moderate, Low, Inactive)
cust_ids = df_customers["customer_id"].tolist()
cust_profiles = {}
for cid in cust_ids:
    r = random.random()
    if r < 0.15:
        # High frequency / Champion
        order_count = random.randint(12, 28)
    elif r < 0.50:
        # Moderate frequency / Loyalist
        order_count = random.randint(6, 12)
    elif r < 0.85:
        # Low frequency / Occasional
        order_count = random.randint(1, 5)
    else:
        # Inactive / Single order
        order_count = random.choices([0, 1], weights=[0.6, 0.4])[0]
    cust_profiles[cid] = order_count

order_counter = 1
for cid, target_orders in cust_profiles.items():
    if target_orders == 0:
        continue
        
    c_row = df_customers[df_customers["customer_id"] == cid].iloc[0]
    c_signup = datetime.date.fromisoformat(c_row["signup_date"])
    c_zone = c_row["zone"]
    c_tier = c_row["tier"]
    c_pmode = c_row["preferred_payment_mode"]
    
    # Hub selection based on zone
    available_hubs = hub_zone_map.get(c_zone, all_hub_ids)
    
    for _ in range(target_orders):
        # Order date between max(signup, 2025-10-01) and 2026-09-30
        eff_start = max(c_signup, order_start)
        if eff_start >= order_end:
            eff_start = order_start
        day_offset = random.randint(0, (order_end - eff_start).days)
        o_date = eff_start + datetime.timedelta(days=day_offset)
        
        # Seasonality weighting
        # October-November (Diwali) and January (Republic Day) spike
        # Monsoon (July-August) delivery delay spike
        is_diwali = (o_date.month in [10, 11])
        is_monsoon = (o_date.month in [7, 8])
        
        chosen_hub = random.choice(available_hubs)
        hub_meta = df_hubs[df_hubs["hub_id"] == chosen_hub].iloc[0]
        hub_type = hub_meta["hub_type"]
        
        # Order status probabilities
        # Normal delivered: 88%, Stockout cancelled: 5%, Customer cancelled: 4%, Returned: 3%
        # If Tier-3 and Monsoon, higher stockout & delay
        if c_tier == "Tier-3" and is_monsoon:
            status = np.random.choice(
                ["Delivered", "Cancelled_Stockout", "Cancelled_Customer", "Returned"],
                p=[0.76, 0.14, 0.06, 0.04]
            )
        elif is_diwali:
            status = np.random.choice(
                ["Delivered", "Cancelled_Stockout", "Cancelled_Customer", "Returned"],
                p=[0.85, 0.08, 0.04, 0.03]
            )
        else:
            status = np.random.choice(
                ["Delivered", "Cancelled_Stockout", "Cancelled_Customer", "Returned"],
                p=[0.90, 0.04, 0.03, 0.03]
            )
            
        # SLA & Delivery time hours
        if hub_type == "Micro-Fulfillment Center" or "KIR" in chosen_hub:
            sla_target = 4.0 # Hyperlocal 4-hour SLA
            base_del_time = np.random.normal(2.5, 1.2)
        elif hub_type == "Regional Hub":
            sla_target = 24.0 # Same day / Next day 24-hr SLA
            base_del_time = np.random.normal(18.0, 6.0)
        else:
            sla_target = 48.0 # Central warehouse 48-hr SLA
            base_del_time = np.random.normal(36.0, 12.0)
            
        # Monsoon friction
        if is_monsoon:
            base_del_time *= 1.35
            
        if status == "Delivered":
            actual_del_time = max(0.8, round(base_del_time, 1))
            del_date = o_date + datetime.timedelta(days=int(actual_del_time // 24) + 1)
            sla_breach = 1 if actual_del_time > sla_target else 0
            if sla_breach:
                cust_rating = random.choices([1, 2, 3, 4], weights=[0.4, 0.35, 0.2, 0.05])[0]
            else:
                cust_rating = random.choices([3, 4, 5], weights=[0.1, 0.35, 0.55])[0]
        else:
            actual_del_time = None
            del_date = None
            sla_breach = 1 if status == "Cancelled_Stockout" else 0
            cust_rating = random.choices([1, 2], weights=[0.75, 0.25])[0] if status in ["Cancelled_Stockout", "Returned"] else None
            
        # Payment mode
        if random.random() < 0.85:
            pmode = c_pmode
        else:
            pmode = random.choice(payment_modes)
            
        oid = f"ORD-{order_counter:06d}"
        orders_list.append((
            oid, cid, chosen_hub, o_date.isoformat(),
            del_date.isoformat() if del_date else None,
            status, pmode, actual_del_time, sla_target, sla_breach, cust_rating
        ))
        
        # Generate 1 to 5 order line items
        num_items = random.choices([1, 2, 3, 4, 5], weights=[0.35, 0.30, 0.20, 0.10, 0.05])[0]
        selected_prods = df_products.sample(n=num_items, replace=False)
        
        for _, p_row in selected_prods.iterrows():
            pid = p_row["product_id"]
            mrp = p_row["mrp_inr"]
            cost = p_row["unit_cost_inr"]
            
            # High value / institutional kirana ordering
            if c_row["customer_type"] == "Micro-Enterprise / Kirana Reseller":
                qty = random.randint(5, 20)
                disc_rate = 0.08
            else:
                qty = random.choices([1, 2, 3, 4], weights=[0.55, 0.30, 0.10, 0.05])[0]
                disc_rate = random.choice([0.0, 0.03, 0.05, 0.10])
                
            unit_price = round(mrp * (1.0 - disc_rate), 2)
            disc_total = round(qty * (mrp - unit_price), 2)
            line_total = round(qty * unit_price, 2)
            
            order_items_list.append((
                f"ITEM-{item_counter:07d}", oid, pid, qty, unit_price, disc_total, line_total
            ))
            item_counter += 1
            
        order_counter += 1

df_orders = pd.DataFrame(orders_list, columns=[
    "order_id", "customer_id", "hub_id", "order_date", "delivery_date",
    "order_status", "payment_method", "delivery_time_hours", "sla_target_hours",
    "sla_breached_flag", "customer_rating"
])
df_orders.to_csv("data/orders.csv", index=False)

df_order_items = pd.DataFrame(order_items_list, columns=[
    "order_item_id", "order_id", "product_id", "quantity", "unit_price_inr",
    "discount_inr", "line_total_inr"
])
df_order_items.to_csv("data/order_items.csv", index=False)

print(f"Generated {len(df_suppliers)} Suppliers")
print(f"Generated {len(df_hubs)} Hubs")
print(f"Generated {len(df_products)} Products")
print(f"Generated {len(df_customers)} Customers")
print(f"Generated {len(df_inventory)} Inventory records")
print(f"Generated {len(df_orders)} Orders")
print(f"Generated {len(df_order_items)} Order Items")

# Step 7: Load into SQLite Database for instant SQL analytics verification
print("Step 7: Creating and Populating SQLite Database (data/ondc_inventory_customer.db)...")
db_path = "data/ondc_inventory_customer.db"
if os.path.exists(db_path):
    os.remove(db_path)
    
conn = sqlite3.connect(db_path)

df_suppliers.to_sql("suppliers", conn, if_exists="replace", index=False)
df_hubs.to_sql("fulfillment_hubs", conn, if_exists="replace", index=False)
df_products.to_sql("products", conn, if_exists="replace", index=False)
df_customers.to_sql("customers", conn, if_exists="replace", index=False)
df_inventory.to_sql("inventory", conn, if_exists="replace", index=False)
df_orders.to_sql("orders", conn, if_exists="replace", index=False)
df_order_items.to_sql("order_items", conn, if_exists="replace", index=False)

# Add indexes
cur = conn.cursor()
cur.execute("CREATE INDEX idx_orders_customer ON orders(customer_id);")
cur.execute("CREATE INDEX idx_orders_hub ON orders(hub_id);")
cur.execute("CREATE INDEX idx_orders_date ON orders(order_date);")
cur.execute("CREATE INDEX idx_order_items_order ON order_items(order_id);")
cur.execute("CREATE INDEX idx_order_items_prod ON order_items(product_id);")
cur.execute("CREATE INDEX idx_inventory_prod ON inventory(product_id);")
cur.execute("CREATE INDEX idx_inventory_hub ON inventory(hub_id);")
conn.commit()
conn.close()

print("Benchmark dataset generation and SQLite database initialization completed successfully!")
