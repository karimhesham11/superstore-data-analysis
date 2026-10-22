# Superstore Sales & Profitability Analysis

**SQL Server · Python · Power BI**

End-to-end analysis of 9,994 order lines (2014–2017) from the Superstore dataset. The business generates **$2.30M in sales but keeps only a 12.47% margin**. This project finds out where discounts, product mix and customer behavior are eating the profit, and what to do about it.

![Superstore Sales & Profitability Overview Dashboard](Dashboard%20Screenshots%20as%20png/1.png)

*The **Executive Overview Dashboard** provides a top-level snapshot of business performance: tracking core KPIs ($2.30M sales, 12.47% profit margin across 5,009 orders), multi-year trends (2014–2017), Q4 seasonality peaks, customer segment distribution, and immediate visibility into sub-category profit drains (notably Tables and Bookcases).*

---

## Business Questions

1. How is the business performing over time, by category and by region?
2. How do discounts affect profitability, and at what level does profit turn negative?
3. Where are the losses concentrated: which sub-categories and products?
4. Which customers drive profit, and which high-sales customers lose money?

## Key Findings

### 1. Discounts of 30% and above destroy profit
| Discount band | Profit margin | Share of order lines | Share of total losses |
|---|---|---|---|
| 0% | 29.51% | 48% | <1% |
| 1–10% | 16.61% | 1% | <1% |
| 11–20% | 11.58% | 37% | 11% |
| 21–30% (effectively 30%) | **-10.05%** | 2% | 7% |
| 31–40% | -19.44% | 2% | 18% |
| 41–50% | -35.71% | 1% | 15% |
| >50% | **-119.20%** | 9% | 49% |

- Order lines discounted **30% or more** are **11.67%** of all lines but account for **81.81%** of total losses, with a combined margin of **-48.2%**.
- The effect differs by category: at a 30% discount **Furniture is already loss-making (-10.75%)**, while **Technology stays profitable (+8.68%)** until discounts go beyond 30%.
- Discount alone does not explain everything: the row-level correlation between discount and profit is weak (≈ -0.22), so the impact depends on the product and category.

### 2. Furniture is the weak spot, and it is concentrated in two sub-categories
- Category margins: **Furniture 2.49%** vs **Office Supplies 17.04%** and **Technology 17.40%**.
- **Tables** account for **78.8%** of losses among loss-making sub-categories, and **Tables + Bookcases for 94.6%**.
- Both are profitable with little or no discount and turn loss-making as discounts rise.

### 3. Category-level numbers hide product-level problems
- **299 products** lose money, for a total loss of about **$76.7K**.
- The **top 3** loss-making products account for **22.56%** of product-level losses, but the losses are also widespread across many smaller products.
- Technology, the most profitable category, still contains several high-impact loss-making products.
- Products were prioritized with percentile-based thresholds on loss amount and margin (Critical / High Financial Impact / Severe Margin Problem / Low Priority).

### 4. Customer value is not the same as customer sales
- 793 customers, **155** of them unprofitable overall.
- **Stars (high sales + high profit):** 133 customers, ≈ $890K sales, ≈ $211K profit, **23.75%** margin.
- **High sales + low profit:** 27 customers, ≈ $181K sales but **-$35.4K profit** (-19.58% margin).
- Profit is spread across a broad customer base: the top 20 customers contribute **26.02%** of profit and the top 50 **44.44%**.

### 5. Growth and seasonality
- Sales grew from $484K (2014) to $733K (2017), with a dip in 2015 ($471K). Profit grew from $49.5K to $93.4K.
- Profit is strongest from September to December, with December the highest month.
- Shipping mode is not a meaningful driver of profitability.

## Recommendations

1. **Avoid discounts of 30% or more.** Set sub-category-specific limits instead of a uniform policy: stricter for Tables and Bookcases, more flexible for resilient sub-categories such as Furnishings and Chairs.
2. **Review the priority list of loss-making products** (pricing, cost and discount history), starting with the Critical and High Financial Impact groups.
3. **Review the high-sales, low-profit customers** before offering them further discounts.
4. **Plan inventory and promotions around September–December**, when profit peaks.

## Dashboard

The Power BI report has four pages, connected with a sidebar navigator and shared slicers (Region, Category, Year).

| Page | Question it answers |
|---|---|
| **Overview** | How is the business performing? KPIs, trend, category and sub-category profitability |
| **Discounts** | At what discount level does profit turn negative, and where? |
| **Products** | Where are the losses concentrated? Loss share by sub-category, top loss-making products, action priority |
| **Customers** | Who drives profit and who loses money? Customer value segments, top and bottom customers |

### Discounts
![Discounts Dashboard](Dashboard%20Screenshots%20as%20png/2.png)

### Products
![Products Dashboard](Dashboard%20Screenshots%20as%20png/3.png)

### Customers
![Customers Dashboard](Dashboard%20Screenshots%20as%20png/4.png)

## Methods

**SQL Server** (`sql/`)
- Aggregations by product, customer, category, sub-category, region, time and shipping mode
- CTEs, window functions (`DENSE_RANK`, running totals, cumulative profit share) and `PERCENTILE_CONT` thresholds
- Discount banding with `CASE` and loss-share analysis

**Python** (`notebooks/`): pandas, NumPy, Matplotlib
- Data checks and cleaning, feature engineering (date parts, discount bands, loss flag, profit margin)
- Exploratory analysis: distributions, IQR outlier detection (1,167 high-value sales kept, not treated as errors), correlations
- Customer segmentation using quartiles of sales and profit (15 value segments, grouped into Stars, High Sales–Losing Money, Small but Profitable and Other), exported to CSV for the Power BI model

**Power BI** (`powerbi/`)
- Star schema: a fact table with customer, product and date dimensions
- DAX measures for KPIs, year-over-year change, loss share and product action priority
- Four-page interactive report with slicers and page navigation

## Repository Structure

```
├── README.md
├── data/            Superstore dataset (and source link)
├── notebooks/       Python analysis
├── sql/             SQL scripts, numbered by topic
├── powerbi/         Power BI report (.pbix)
├── dashboard/       Dashboard screenshots
└── requirements.txt
```

**To reproduce:** load the dataset into SQL Server and run the scripts in `sql/`; run the notebook in `notebooks/` (it exports `customer_segments.csv`); open the `.pbix` in Power BI Desktop and point the data source to your local copy.

## Limitations

- The dataset has no cost data, so profit is used as given and cost drivers cannot be investigated.
- Findings show association, not causation. Some category × region × discount groups have few order lines, so they are read with caution.
- The data covers four years, so seasonality conclusions are indicative.
- Customer segments are relative (quartile-based), not absolute business rules.

## Author

**Karim Hesham** · Junior Data Analyst
[LinkedIn](https://linkedin.com/in/karim-hesham-847963300) · [GitHub](https://github.com/karimhesham11)
