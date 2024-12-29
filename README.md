This [dbt](https://github.com/dbt-labs/dbt) package contains macros that can be (re)used across dbt projects.

Note:
- Currently, only methods for unordered distinct item sets are supported. I.e. methods for sequence or vector similarity are not included in this package
- Input fields to all function are expected to be array/variant type
- All methods in this package are meant to be used inline within a select statement.

**Current supported/tested databases include:**
- Postgres
- Snowflake
- DuckDB


| **Method**        | **Postgres** | **Snowflake** | **DuckDB** |
|---------------------|--------------|---------------|------------|
| **dice_coef**       | ✅           | ✅             | ✅          |
| **jaccard_coef**    | ✅           | ✅             | ✅          |
| **overlap_coef**    | ✅           | ✅             | ✅          |
| **tversky_coef**    | ✅           | ✅             | ✅          |


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
    * [dice_coef](#dice_coef)
    * [jaccard_coef](#jaccard_coef)
    * [overlap_coef](#overlap_coef)
    * [tversky_coef](#tversky_coef)

----

## Methods

### dice_coef
([source](macros/dice_coef.sql))

The Dice coefficient (also known as the Sørensen-Dice index) is a similarity measure that compares the overlap between two sets by considering the ratio of their intersection to the sum of their sizes. It is defined as:

$$Dice(A,B) = \frac{2 * |A \cap B |}{|A| + |B|}
$$
​

This coefficient ranges from 0 (no overlap) to 1 (identical sets), giving double weight to common elements. It is especially useful for comparing sets with binary or categorical elements, where the goal is to quantify how similar two sets are based on their shared elements.

**Args:**

- `column_one` (required): Name of the first field or relevant SQL transformation to use holding the array/set
- `column_two` (required): Name of the second field or relevant SQL transformation to use holding the array/set

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

- `column_one` (required): Name of the first field or relevant SQL transformation to use holding the array/set
- `column_two` (required): Name of the second field or relevant SQL transformation to use holding the array/set

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

- `column_one` (required): Name of the first field or relevant SQL transformation to use holding the array/set
- `column_two` (required): Name of the second field or relevant SQL transformation to use holding the array/set

**Usage:**

```sql
{{ dbt_set_similarity.overlap_coef(
    column_one='first_set_of_items',
    column_two='second_set_of_items',
   )
}}
```

### tversky_coef
([source](macros/tversky_coef.sql))

The Tversky Index is a similarity measure that generalizes the overlap between two sets, allowing for adjustable weights on asymmetric differences between the sets. It is defined as:

$$
Tversky(A,B) = \frac{|A \cap B |}{|A \cap B | + \alpha |A - B| + \beta |B - A|}
$$

where $|A - B|$ denotes the relative complement of A in B

This coefficient ranges from 0 (no similarity) to 1 (identical sets) and is especially useful when comparing sets of different sizes or when wanting to emphasize specific asymmetries between the sets.

**Args:**

- `column_one` (required): Name of the first field or relevant SQL transformation to use
- `column_two` (required): Name of the second field or relevant SQL transformation to use
- `alpha` (optional): Weight for elements unique to A. Default is 0.5
- `beta` (optional): Weight for elements unique to B. Default is 0.5

**Usage:**

```sql
{{ dbt_set_similarity.overlap_coef(
    column_one='first_set_of_items',
    column_two='second_set_of_items',
    alpha=0.75,
    beta=0.25,
   )
}}
```
