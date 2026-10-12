# Project BHARAT-FLOW: ONDC Pan-India Retail Inventory & Customer Lifecycle Intelligence

> **A Comprehensive Multi-Echelon Supply Chain & Customer Analytics Project Powered by SQL and Excel BI**  
> *Grounded in India's Open Network for Digital Commerce (ONDC) and Pradhan Mantri Bhartiya Janaushadhi Pariyojana (PMBJP) Ecosystem*

---

## 📌 1. Project Overview & Institutional Context

**Project BHARAT-FLOW** is a data analytics repository and decision-support system modeling a pan-India retail supply chain operating over the **Open Network for Digital Commerce (ONDC)** (DPIIT, Ministry of Commerce and Industry) and the **Pradhan Mantri Bhartiya Janaushadhi Pariyojana (PMBJP)** (Pharmaceuticals & Medical Devices Bureau of India - PMBI).

In traditional e-commerce, proprietary platforms monopolize customer discovery, warehousing, delivery, and payments in closed silos. ONDC unbundles this ecosystem by enabling open network discovery where:
- **Buyer Applications** (e.g., Paytm, Magicpin, Mystore) capture diverse customer demand across Indian metro and regional towns.
- **Seller Network Participants (SNPs)** and **Hyperlocal Kiranas** list inventory digitally via open Beckn protocols.
- **Fulfillment Networks** coordinate multi-echelon inventory flows across Central Warehouses (CWH), Regional Distribution Hubs (RDH), Urban Dark Stores (MFC), and neighborhood Kirana nodes.

### Why This Project is Unique
While generic retail supply chain projects use synthetic western superstore data, **BHARAT-FLOW** is built upon the structural realities of the Indian retail grid:
1. **Multi-Echelon Indian Topology**: Spanning 6 geographic zones (North, South, East, West, Central, North-East) across Tier-1 Metros (Delhi, Mumbai, Bengaluru), Tier-2 Commercial Hubs (Lucknow, Jaipur, Patna, Bhopal, Coimbatore, Guwahati), and Tier-3 Towns (Jammu, Darbhanga, Warangal, Silchar).
2. **Dual FMCG & Healthcare Essential Catalogs**: Incorporating everyday branded staples (Aashirvaad Atta, Fortune Oil, Tata Salt, Amul Dairy) alongside high-priority generic pharmaceuticals from Jan Aushadhi Kendras (Paracetamol 650, Metformin 500, ORS, Cetirizine).
3. **Real-World Indian Friction Dynamics**: Modeling monsoon transport shocks (July–August), festive pre-stocking surges (Diwali/Dussehra), phantom inventory at kirana counters, UPI/RuPay payment adoption, and customer churn causality driven by delivery SLA breaches.

---

## 📂 2. Repository Structure

```
.
├── README.md                                    # Master project documentation & architectural guide
├── data/                                        # Grounded benchmark CSV datasets
│   ├── suppliers.csv                            # 12 National manufacturers & pharma PSUs
│   ├── fulfillment_hubs.csv                     # 17 Multi-echelon logistics facilities
│   ├── products.csv                             # 35 Core FMCG & Jan Aushadhi healthcare SKUs
│   ├── customers.csv                            # 1,200 Registered retail & enterprise accounts
│   ├── inventory.csv                            # 595 Multi-location SKU stock snapshots
│   ├── orders.csv                               # 8,866 Annual transaction orders (FY25–26)
│   └── order_items.csv                          # 19,349 Line items with prices, costs & discounts
├── sql/                                         # Production SQL analytical query suites
│   ├── 01_schema_ddl.sql                        # DDL table creation, foreign keys & indexes
│   ├── 02_data_ingestion.sql                    # Bulk ingestion scripts (COPY / LOAD DATA)
│   ├── 03_descriptive_analysis.sql              # Type 1: Baseline health, valuation & GMV
│   ├── 04_diagnostic_analysis.sql               # Type 2: Root-cause stockouts, delays & churn
│   └── 05_predictive_prescriptive_analysis.sql  # Type 3: ABC-XYZ, ROP/EOQ & RFM CLV models
├── excel/                                       # Excel BI Deliverables
│   └── ONDC_India_Inventory_Customer_BI_Model.xlsx # Complete multi-sheet BI workbook with charts
├── reports/                                     # Research & Analytics Deliverables
│   ├── ONDC_India_Inventory_Customer_Report.md  # Exhaustive research report in Markdown
│   └── India_Retail_SupplyChain_Inventory_Customer_Report.pdf # 12-page executive publication PDF
└── scripts/                                     # Automated data generation & pipeline scripts
    ├── generate_benchmark_data.py               # Benchmark data generation engine
    ├── load_sqlite.py                           # SQLite database populator & indexer
    ├── test_all_sql.py                          # Deterministic SQL testing suite
    ├── run_sql_analytics.py                     # Command-line query executor & table display
    ├── generate_charts.py                       # Matplotlib high-resolution figure generator
    └── build_html_report.py                     # Report compiler & HTML builder
```

---

## 📊 3. Analytical Framework: Demonstrating 3 Types of Data Analysis

Project BHARAT-FLOW implements three distinct, rigorous layers of data analysis:

### Type 1: Descriptive Analytics (Baseline Health & Macro KPIs)
- **Macro Inventory Valuation**: Quantifies working capital tied up across 17 facilities (₹3.14M inventory value; ₹584K annual carrying cost; 65% CWH utilization vs 48% Kirana utilization).
- **Category Economics**: Analyzes unit sales, gross merchandise value (GMV), COGS, and gross margins across 5 product categories (Packaged Food & Staples: ₹1.93M GMV, 13.5% margin; Essential Pharma: ₹412K GMV, 35.0% margin; Dairy: 14.6 annual turns).
- **Geographic Penetration**: Profiles customer activation rates, total delivered spend, and Average Order Value (AOV) across Tier-1, Tier-2, and Tier-3 urban cohorts.
- **Payment Stack Architecture**: Measures UPI penetration (60.7% share), RuPay debit (14.3%), NetBanking (11.3%), and Cash on Delivery (13.7%).

### Type 2: Diagnostic Analytics (Root-Cause Attribution & Friction Discovery)
- **Stockout Attribution by Echelon**: Isolates that order cancellations due to stockouts are concentrated at the periphery (15.43% cancellation rate at Tier-3 Kirana SNPs vs 5.23% at Tier-1 Central Warehouses), exposing the "phantom inventory" phenomenon where physical sales are not synchronized in real-time.
- **Supplier Lead-Time Volatility**: Correlates supplier lead-time standard deviation ($\sigma_L$) with stockouts. Demonstrates that BPPI/PMBJP generic pharma distribution ($\sigma_L = 2.4$ days) generates 48 network stockout incidents, whereas dairy suppliers with $\sigma_L \le 0.6$ days maintain stable stock-to-safety ratios (>4.0).
- **Customer Churn Causality**: Proves that customers experiencing an on-time first delivery achieve an **88.46% repeat purchase rate**, whereas an initial SLA delay cuts retention to **46.15%**, and an initial stockout cancellation collapses retention to **18.42%** (destroying 84.8% of lifetime GMV).
- **Monsoon & Festive Shock Analysis**: Identifies that monsoon weather in July–August causes delivery transit times to jump by 61.3% (from 15.0 to 24.2 hours) and SLA breaches to escalate to 33.1%.

### Type 3: Predictive & Prescriptive Analytics (Optimization & Segmentation)
- **Multi-Dimensional ABC-XYZ Matrix**:
  - *ABC Classification*: Evaluates Pareto annual consumption value ($A \le 80\%$, $B \le 95\%$, $C > 95\%$).
  - *XYZ Classification*: Evaluates monthly demand volatility via Coefficient of Variation ($CV = \sigma_D / \mu_D$; $X \le 0.45$, $Y \le 0.85$, $Z > 0.85$).
  - *9-Box Policy Assignment*: Assigns targeted inventory control rules (AX = Just-In-Time Continuous Replenishment; AY = Dynamic Buffer Review; BX = Periodic Reorder; CZ = Decentralized On-Demand Procurement).
- **Stochastic Safety Stock & Dynamic ROP Modeling**:
  - Incorporates dual uncertainty in both daily demand ($\sigma_d$) and supplier lead time ($\sigma_L$):
    $$SS_i = Z \times \sqrt{L_i \cdot \sigma_{d, i}^2 + d_i^2 \cdot \sigma_{L, i}^2} \quad (Z = 1.65 \text{ for } 95\% \text{ SLA})$$
    $$ROP_i = (d_i \times L_i) + SS_i$$
    $$EOQ_i = \sqrt{\frac{2 \cdot D_i \cdot S_i}{C_i \cdot h_i}}$$
  - Identifies critical deficits in PMBJP generic drugs (Paracetamol and Metformin operating below safety buffers).
- **Customer RFM Segmentation & Predictive CLV**:
  - Evaluates 1,056 active buyers on Recency ($R$, days to Sep 30, 2026), Frequency ($F$, delivered orders), and Monetary Spend ($M$, total GMV) using quintile scoring ($NTILE(5)$).
  - Segments base into Champions (15.9% of customers, generating 46.2% of GMV), Loyal Customers (28.8% GMV), Potential Loyalists, At Risk / Slipping (118 customers with ₹310K at-risk GMV), and Hibernating.
  - Deploys targeted prescriptive retention playbooks (VIP rapid dispatch, automated bundling, ₹75 second-order UPI cashback, staple win-back SMS).

---

## 📈 4. Excel BI Model Architecture

The workbook `ONDC_India_Inventory_Customer_BI_Model.xlsx` is structured as a financial and operational business intelligence model:

1. **Executive_Dashboard**:
   - Merged Navy header banner (`A1:H2`) with subtitle.
   - Symmetrical 4-KPI scorecard cards (`A3:B5`, `C3:D5`, `E3:F5`, `G3:H5`) with large values and context labels.
   - Table 1: Category Gross Revenue, COGS, Profit, Margin %, and Inventory Turns with dynamic Excel formulas.
   - Table 2: City Tier Performance (Customers, Orders, GMV, AOV, SLA Breach %, Stockout %).
   - Embedded native Column Chart (`BarChart`) comparing Category Revenue vs Gross Profit.
2. **Inventory_ABC_XYZ**:
   - SKU-level data sheet for 35 products with dynamic consumption values, cumulative value percentages, ABC classification formulas (`IF`), demand CV, XYZ classification formulas, Safety Stock, Reorder Point, and EOQ formulas.
   - Freeze panes on data headers (`C6`).
3. **Customer_RFM_Analysis**:
   - Granular customer sheet for 1,056 active customers with calculated Recency, Frequency, Monetary spend, AOV formulas, RFM segments, and prescriptive action recommendations.
4. **Logistics_Hub_Diagnostic**:
   - 17 fulfillment facilities with order volumes, delivered counts, SLA breach rates, and stockout cancellation percentages.
   - Embedded native Bar Chart displaying hub volume against stockout rates.
5. **Assumptions_Data_Model**:
   - Comprehensive data dictionary, parameter definitions, mathematical formulas, and business assumptions.

*Quality Assurance*: Deterministically audited via `validate_excel.py` with **0 formula errors** and fully evaluated formula trees via headless LibreOffice.

---

## 💻 5. How to Run the Pipeline

### Prerequisites
- Python 3.10+ (with `pandas`, `openpyxl`, `matplotlib`, `seaborn`, `numpy`)
- SQLite3 or PostgreSQL / MySQL / DuckDB
- LibreOffice (for headless Excel formula recalculation)

### Step 1: Generate Benchmark Data
```bash
python3 scripts/generate_benchmark_data.py
```
*Outputs clean CSV files into `data/`.*

### Step 2: Initialize SQLite Database
```bash
python3 scripts/load_sqlite.py
```
*Creates indexed tables in `/tmp/ondc_inventory_customer.db`.*

### Step 3: Execute SQL Analytics Suites
```bash
python3 scripts/run_sql_analytics.py
```
*Executes all queries from `sql/03_descriptive_analysis.sql`, `sql/04_diagnostic_analysis.sql`, and `sql/05_predictive_prescriptive_analysis.sql` and prints tabular outputs.*

### Step 4: Build and Validate the Excel BI Model
```bash
python3 artifacts/file_generation/ttl=63d/intermediate/build_excel_bi.py
```
*Builds `excel/ONDC_India_Inventory_Customer_BI_Model.xlsx` and executes deterministic validation.*

### Step 5: Compile Publication Report
```bash
python3 scripts/generate_charts.py
python3 scripts/build_html_report.py
python3 skills/pdf-processing/scripts/compile_and_render.py artifacts/file_generation/ttl=63d/intermediate/document.html artifacts/file_generation/ttl=63d/output/India_Retail_SupplyChain_Inventory_Customer_Report.pdf
```
*Compiles the 12-page executive report PDF.*

---

## 📜 6. Citations & References

1. **Department for Promotion of Industry and Internal Trade (DPIIT)**, Ministry of Commerce and Industry, Government of India. *Open Network for Digital Commerce (ONDC): Strategy Paper and Architectural Blueprint*. [https://ondc.org/](https://ondc.org/)
2. **Pharmaceuticals & Medical Devices Bureau of India (PMBI)**, Ministry of Chemicals and Fertilizers. *Pradhan Mantri Bhartiya Janaushadhi Pariyojana (PMBJP)*. [https://janaushadhi.gov.in/](https://janaushadhi.gov.in/)
3. **National Payments Corporation of India (NPCI)**. *Unified Payments Interface (UPI) Product Ecosystem*. [https://www.npci.org.in/](https://www.npci.org.in/)
4. **Open Government Data (OGD) Platform India**. *Essential Commodity Buffer Stocks*. [https://data.gov.in/](https://data.gov.in/)
5. **Silver, E. A., Pyke, D. F., & Thomas, D. J.** (2016). *Inventory and Production Management in Supply Chains*. CRC Press.
6. **Fader, P. S., Hardie, B. G., & Lee, K. L.** (2005). *RFM and CLV: Using Iso-Value Curves for Customer Base Analysis*. Journal of Marketing Research.
