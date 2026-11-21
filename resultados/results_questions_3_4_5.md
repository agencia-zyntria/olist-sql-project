# Olist · Answers to questions 3, 4 and 5

Analysis date: 2026-11-21. Source: original CSVs from [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), version 2.

The queries were executed in SQLite over the original CSVs. Their logic was checked against independent pandas calculations, including monetary totals checked in exact decimal arithmetic. Validation against the final MySQL database is pending.

## Scope and definitions

- The source contains 99,441 orders.
- The analysis includes 96,470 delivered orders with both delivery dates available. It excludes 8 orders marked delivered that have a missing delivery date.
- There are 6,534 late orders, representing 6.77% of eligible delivered orders.
- A late order arrives on a calendar day after its estimated delivery day.
- A low rating is a score of 1 or 2.
- For orders with multiple reviews, the latest answered review is used. Ties use review creation date, review ID and score in descending order.
- 95,824 eligible orders have a selected valid review. Missing reviews stay outside rating averages and low-rating percentages.
- Customer state comes from customers.customer_state.
- Categories use the English translation where available and the original Portuguese name otherwise. Missing categories appear as unknown.
- The category analysis counts one order per category. Multi-category orders contribute to multiple groups. The review score describes the entire order.
- Question 5 uses the sum of item prices in BRL, excluding freight.

## Question 3 · Which states have the most delayed orders?

By volume, **SP** leads with **1,820 late orders**, a delay rate of **4.49%** among its 40,494 eligible delivered orders.

### Top five states by delay count

| customer_state | delivered_orders | delayed_orders | delayed_percentage |
| --- | --- | --- | --- |
| SP | 40494 | 1820 | 4.49 |
| RJ | 12350 | 1495 | 12.11 |
| MG | 11354 | 519 | 4.57 |
| BA | 3256 | 396 | 12.16 |
| RS | 5344 | 325 | 6.08 |

### Top five states by delay rate

| customer_state | delivered_orders | delayed_orders | delayed_percentage |
| --- | --- | --- | --- |
| AL | 397 | 85 | 21.41 |
| MA | 717 | 125 | 17.43 |
| SE | 335 | 51 | 15.22 |
| PI | 476 | 66 | 13.87 |
| CE | 1279 | 176 | 13.76 |

**AL** has the highest delay rate, **21.41%**, based on 85 late orders out of 397 eligible deliveries.

**Conclusion.** Prioritization can consider both the large number of affected orders in SP and the elevated delay rates in AL, MA and SE. Their different order volumes remain visible in the tables.

## Question 4 · Which categories accumulate delays or low ratings?

**bed_bath_table** leads by delay count, with **689 late orders** and a **7.43%** delay rate.

### Top five categories by delay count

| category | delivered_orders | delayed_orders | delayed_percentage |
| --- | --- | --- | --- |
| bed_bath_table | 9272 | 689 | 7.43 |
| health_beauty | 8647 | 649 | 7.51 |
| sports_leisure | 7529 | 495 | 6.57 |
| furniture_decor | 6307 | 449 | 7.12 |
| computers_accessories | 6529 | 417 | 6.39 |

### Top five categories by low-rating count

| category | reviewed_orders | low_rating_orders | low_rating_percentage | average_review_score |
| --- | --- | --- | --- | --- |
| bed_bath_table | 9177 | 1471 | 16.03 | 4.0 |
| health_beauty | 8601 | 985 | 11.45 | 4.23 |
| furniture_decor | 6260 | 961 | 15.35 | 4.06 |
| computers_accessories | 6498 | 945 | 14.54 | 4.08 |
| sports_leisure | 7485 | 852 | 11.38 | 4.23 |

**bed_bath_table** also leads by low-rating count, with **1,471 orders rated 1 or 2**, or **16.03%** of its reviewed eligible orders.

**Conclusion.** Bed, bath and table products are a priority for investigating delivery and customer experience because they lead both counts. Health and beauty products also have a large number of delayed orders. Category-level order counts and percentages provide the context for those rankings.

## Question 5 · How much revenue is associated with late orders with low ratings?

| Measure | Value |
| --- | --- |
| Late orders rated 1 or 2 | 3,983 |
| Item sales in these orders | 619,012.41 BRL |
| Item sales across all eligible delivered orders | 13,220,248.93 BRL |
| Share of eligible item sales | 4.68% |

**Conclusion.** Late orders with low ratings account for **619,012.41 BRL**, or **4.68%** of eligible item sales. This is a descriptive indicator of sales associated with a poor delivery and review outcome. Estimating refunds, future customer spending or lost sales would require additional data and analysis.

## Reproduce and integrate

1. Keep queries.sql and consultas_csv.ipynb in the repository root, with the original CSVs in datos/.
2. Execute all cells in consultas_csv.ipynb to regenerate the three CSVs and this report in resultados/.
3. Agree the late-delivery, low-rating and review-selection rules with the teammate responsible for cleaning orders and reviews.
4. Execute queries.sql against the final MySQL tables and reconcile the results before the final presentation.

Data attribution: Olist, Brazilian E-Commerce Public Dataset by Olist, Kaggle. The derived CSV result tables follow the dataset's [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.
