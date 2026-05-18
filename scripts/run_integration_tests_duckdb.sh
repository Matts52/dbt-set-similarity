#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INT_TESTS_DIR="$REPO_ROOT/integration_tests"

echo "=== dbt-set-similarity Integration Tests (DuckDB) ==="
echo ""

mkdir -p "$REPO_ROOT/duckdb"

cd "$INT_TESTS_DIR"

echo "1. Installing dependencies..."
dbt deps --profile integration_tests_duckdb

echo ""
echo "2. Loading seed data..."
dbt seed --profile integration_tests_duckdb

echo ""
echo "3. Running dbt models..."
dbt run --profile integration_tests_duckdb

echo ""
echo "4. Running tests..."
dbt test --profile integration_tests_duckdb

echo ""
echo "=== All tests passed! ==="
