# RetailNova Analytics

## End-to-End Retail Business Intelligence Project

RetailNova Analytics is an end-to-end retail analytics and business intelligence project designed to simulate the analytics environment of a large Indian omnichannel retailer.

The project transforms raw operational data into validated business metrics, analytical SQL datasets, reusable Stored Procedures, and interactive Power BI dashboards.

---

## Project Objective

The objective is to build a complete end-to-end analytics pipeline that transforms raw retail operational data into reliable business intelligence.

The project follows the complete analytical lifecycle:

**Raw Data → MySQL → Data Validation → SQL EDA → Stored Procedures → Power BI → DAX → Business Dashboards → Business Insights**

### Project Architecture

# RetailNova Analytics

## End-to-End Retail Business Intelligence Project

RetailNova Analytics is an end-to-end retail analytics and business intelligence project designed to simulate the analytics environment of a large Indian omnichannel retailer.

The project transforms raw operational data into validated business metrics, analytical SQL datasets, reusable Stored Procedures, and interactive Power BI dashboards.

---

## Project Objective

The objective is to build a complete end-to-end analytics pipeline that transforms raw retail operational data into reliable business intelligence.

The project follows the complete analytical lifecycle:

**Raw Data → MySQL → Data Validation → SQL EDA → Stored Procedures → Power BI → DAX → Business Dashboards → Business Insights**

### Project Architecture

```mermaid
flowchart TD

    A["Source Data<br/>CSV / Master Data / Transaction Data"]
    B["MySQL<br/>Relational Database"]
    C["Data Quality & Validation<br/>Nulls / Duplicates / Referential Integrity"]
    D["SQL EDA<br/>Business & Trend Analysis"]
    E["Stored Procedures<br/>Reusable Business Logic"]
    F["Power BI<br/>Data Model + Power Query"]
    G["DAX<br/>KPIs & Analytical Measures"]
    H["Business Dashboards"]
    I["Business Insights<br/>Management Decision Support"]

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
