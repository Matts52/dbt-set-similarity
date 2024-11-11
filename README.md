This [dbt](https://github.com/dbt-labs/dbt) package contains macros that can be (re)used across dbt projects.

Notes:
- Currently, only methods for unordered distinct item sets are supported. I.e. methods for sequence or vector similarity are not included in this package
- All methods in this package are meant to be used inline within a select statement.

**Current supported/tested databases include:**
- Postgres
- Snowflake

## Installation Instructions

To import this package into your dbt project, add the following to either the `packages.yml` or `dependencies.yml` file:

```
packages:
  - package: "Matts52/dbt_set_similarity"
    version: [">=0.1.0"]
```

and run a `dbt deps` command to install the package to your project.

Check [read the docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## dbt Versioning

This package currently support dbt versions 1.1.0 through 2.0.0

## Adapter Support

Currently this package supports the Snowflake and Postgres adapters

----

* [Installation Instructions](#installation-instructions)
* [Methods](#methods)
    * [dice_coef](#dice_coefficient)
    * [jaccard_coef](#jaccard_coefficient)
    * [overlap_coef](#overlap_coefficient)

----

## Methods

### dice_coef
([source](macros/dice_coef.sql))

The Dice coefficient (also known as the Sørensen-Dice index) is a similarity measure that compares the overlap between two sets by considering the ratio of their intersection to the sum of their sizes. It is defined as:

$$
Dice(A,B) = \frac{2|A \cap B |}{|A| + |B|}
$$
​
This coefficient ranges from 0 (no overlap) to 1 (identical sets), giving double weight to common elements. It is especially useful for comparing sets with binary or categorical elements, where the goal is to quantify how similar two sets are based on their shared elements.

**Args:**

- `column_one` (required): Name of the first field or relevant SQL transormation to use
- `column_two` (required): Name of the second field or relevant SQL transormation to use

**Usage:**

```sql
{{ dbt_set_similarity.dice_coef(
    column_one='first_set_of_items',
    column_two='second_set_of_items',
   )
}}
```

### jaccard_coef
([source](macros/jaccard_coef.sql))

The Jaccard coefficient (also known as the Jaccard index) is a similarity measure that quantifies the similarity between two sets based on the ratio of their intersection to their union. It is defined as:

$$
Jaccard(A,B) = \frac{|A \cap B |}{|A \cup B|}
$$

This coefficient ranges from 0 (no overlap) to 1 (identical sets), indicating how similar two sets are by comparing the number of shared elements relative to the total distinct elements in both sets.

**Args:**

- `column_one` (required): Name of the first field or relevant SQL transormation to use
- `column_two` (required): Name of the second field or relevant SQL transormation to use

**Usage:**

```sql
{{ dbt_set_similarity.jaccard_coef(
    column_one='first_set_of_items',
    column_two='second_set_of_items',
   )
}}
```

### overlap_coef
([source](macros/overlap_coef.sql))

The Overlap coefficient is a similarity measure that compares the overlap between two sets by evaluating the ratio of their intersection to the size of the smaller set. It is defined as:

$$
Overlap(A,B) = \frac{|A \cap B |}{min(|A|, |B|)}
$$

This coefficient ranges from 0 (no overlap) to 1 (identical sets), focusing on how much the two sets share relative to the size of the smaller set. It is especially useful when the size of the sets may differ significantly and you want to measure the similarity based on the shared elements.

**Args:**

- `column_one` (required): Name of the first field or relevant SQL transormation to use
- `column_two` (required): Name of the second field or relevant SQL transormation to use

**Usage:**

```sql
{{ dbt_set_similarity.overlap_coef(
    column_one='first_set_of_items',
    column_two='second_set_of_items',
   )
}}
```
