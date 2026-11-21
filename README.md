# Olist · Delivery and Satisfaction Analysis

SQL project on Olist’s e-commerce operations in Brazil. The goal is to analyze the relationship between delivery delays and customer satisfaction, and to identify where to prioritize improvements in logistics and the shopping experience.

## Dataset

[**Brazilian E-Commerce Public Dataset by Olist**](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist on Kaggle, version 2. It contains 99,441 orders from 2016 to 2018 and their associated data on customers, items, sellers, payments, products, and reviews. The original CSV files and the derived cleaned tables are distributed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

| Project Table | Source CSV |
| --- | --- |
| `orders` | `olist_orders_dataset.csv` |
| `customers` | `olist_customers_dataset.csv` |
| `order_reviews` | `olist_order_reviews_dataset.csv` |
| `order_payments` | `olist_order_payments_dataset.csv` |
| `order_items` | `olist_order_items_dataset.csv` |
| `products` | `olist_products_dataset.csv` |
| `sellers` | `olist_sellers_dataset.csv` |
| `category_translation` | `product_category_name_translation.csv` |

Kaggle includes a ninth CSV file, `olist_geolocation_dataset.csv`, which is excluded from the analysis. `orders` is the central table. To determine whether the same person makes repeat purchases, they are identified by `customers.customer_unique_id`, since `customer_id` may change between orders.

## Business Questions

**Main Question.** How do delivery delays relate to customer satisfaction?

1. What percentage of orders arrive after the estimated delivery date?
2. What is the average rating for orders delivered on time compared to those delivered late?
3. In which Brazilian states are there the most delays?
4. Which product categories have the most delays or low ratings?
5. How much revenue is at risk from delayed orders and those with low ratings?
6. Do customers who have received a late order buy less often?

## Work Breakdown

| Task | Orders and Customers | Products and Sellers |
| --- | --- | --- |
| Exploration and Cleaning | `orders`, `customers`, `order_reviews`, and `order_payments`. Review of dates, undelivered orders, and duplicate reviews. | `order_items`, `products`, `sellers`, and `category_translation`. Review of prices, empty categories, and English translations. |
| Phase 3 Deliverables | Diagram of the eight tables with primary and foreign keys, and `create.sql` with the definitions for MySQL. | Repository’s `README.md`. |
| SQL Queries | Questions 1, 2, and 6. | Questions 3, 4, and 5. |

Each team member works on their own laptop and saves their four cleaned CSV files in `data/cleaned/`. Loading the data into MySQL and validating the counts will be done in a joint session. During the presentation, each team member will present their questions, and both will prepare the conclusions.

## Data Preparation

1. If you already have a clone of the repository, run `git pull` before you start working.
2. Click **Download** on the Kaggle page and extract the CSV files directly into `data/`, at the same level as this README.
3. To run the notebooks in JupyterLab, install the dependencies with `python -m pip install “pandas>=2.2” jupyterlab` and open JupyterLab from the root of the repository with `python -m jupyterlab`. You can also open the notebooks in VS Code using an environment that includes pandas.
4. Run the notebook for each block when it becomes available in the repository. Both check rows, columns, null values, duplicates, and keys in their respective tables. The outputs retain the names of the Kaggle CSV files and are written to `data/cleaned/`.

The `/data/` rule in `.gitignore` excludes both the original and cleaned CSV files from Git.

## Decisions Regarding the Cleanup of Products and Sellers

- All rows for items, products, and sellers are retained. The 610 uncategorized products have an empty field. Known categories are translated using the category table, with two additional mappings added to cover 13 products.
- The item price and shipping cost are kept in separate columns, with two decimal places. The 383 shipping costs with a value of zero are retained.
- The source headers and leading zeros in the ZIP code prefixes are preserved. The notebook records weight values equal to zero and empty dimension fields so that subsequent queries can decide how to handle them.
