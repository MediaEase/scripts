# modules/database.sh

## Overview

Contains a library of database functions used in the MediaEase project.

## Index

* [zen::database::query](#zendatabasequery)
* [zen::database::select](#zendatabaseselect)
* [zen::database::select::count](#zendatabaseselectcount)
* [zen::database::select::inner_join](#zendatabaseselectinnerjoin)
* [zen::database::insert](#zendatabaseinsert)
* [zen::database::update](#zendatabaseupdate)
* [zen::database::delete](#zendatabasedelete)
* [zen::database::load_config](#zendatabaseloadconfig)
* [zen::database::load_joined_config](#zendatabaseloadjoinedconfig)

### zen::database::query

Executes a given SQLite3 query on the database.

#### Arguments

* **$1** (string): SQLite3 query to be executed.

#### Output on stdout

* Outputs the query result or errors.

### zen::database::select

Executes a SELECT COUNT operation on the database.

#### Arguments

* **$1** (string): Name of the table for counting records.
* **$2** (string): Columns to be counted (optional, defaults to '*').
* **$3** (string): Conditions for counting (optional).
* **$4** (string): Additional SQL clauses like ORDER BY, GROUP BY (optional).

#### Output on stdout

* Outputs the count result or errors.

### zen::database::select::count

Executes a SELECT COUNT operation on the database.

#### Arguments

* **$1** (string): Name of the table for counting records.
* **$2** (string): Columns to be counted (optional, defaults to '*').
* **$3** (string): Conditions for counting (optional).
* **$4** (string): Additional SQL clauses like ORDER BY, GROUP BY (optional).

#### Output on stdout

* Outputs the count result or errors.

### zen::database::select::inner_join

Executes an INNER JOIN SELECT operation on the database.

#### Arguments

* **$1** (string): Columns to be selected.
* **$2** (string): Name of the primary table with alias.
* **$3** (string): Inner join clause with the table and alias.
* **$4** (string): Conditions for selection (optional).
* **$5** (string): Additional SQL clauses like ORDER BY, GROUP BY (optional).
* **$6** (string): Flag for DISTINCT selection (optional, set to '1' for DISTINCT).

#### Output on stdout

* Outputs the query result or errors.

### zen::database::insert

Executes an INSERT operation on the database.

#### Arguments

* **$1** (string): Name of the table to insert into.
* **$2** (string): Comma-separated list of columns for the insert operation.
* **$3** (string): Comma-separated list of values corresponding to the columns.

#### Output on stdout

* Outputs the query result or errors.

### zen::database::update

Executes an UPDATE operation on the database.

#### Arguments

* **$1** (string): Name of the table to update.
* **$2** (string): Column-value pairs for the update operation.
* **$3** (string): Conditions specifying which records to update.

#### Output on stdout

* Outputs the query result or errors.

### zen::database::delete

Executes a DELETE operation on the database.

#### Arguments

* **$1** (string): Name of the table to delete from.
* **$2** (string): Conditions specifying which records to delete.

#### Output on stdout

* Outputs the query result or errors.

### zen::database::load_config

Parses SQL query results into an associative array.

#### Arguments

* **$1** (string): Result of the SQL query.
* **$2** (string): Reference to the associative array for query results.
* **$3** (string): Index of the identifier column in the query result.
* **$4** (string): Array of column names corresponding to the query result.

#### Output on stdout

* Populates the provided associative array with query results.

### zen::database::load_joined_config

Parses SQL inner join query results into global variables.

#### Arguments

* **$1** (string): Result of the SQL inner join query.
* **$2** (string): Prefix for global variable names.
* **$3** (string): Array of column names corresponding to the query result.

#### Output on stdout

* Sets global variables for each column value in the query result.
