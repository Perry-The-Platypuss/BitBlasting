#!/bin/bash

# Usage: bash q1_2.sh <universal_itemset> <num_transactions>
# Generates ./generated_transactions.dat in the current q1 directory.

if [ "$#" -ne 2 ]; then
    echo "Usage: bash q1_2.sh <universal_itemset> <num_transactions>"
    exit 1
fi

ITEMSET="$1"
NUM_TX="$2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DATASET="$SCRIPT_DIR/generated_transactions.dat"

python3 "$SCRIPT_DIR/generate_transactions.py" "$ITEMSET" "$NUM_TX" "$OUT_DATASET"

# Optional: rerun Task-1 pipeline on the generated dataset if requested.
# Set RUN_Q1_1=1 to enable.
if [ "$RUN_Q1_1" = "1" ]; then
    APRIORI_EXEC="$SCRIPT_DIR/apriori/apriori/src/apriori"
    FP_EXEC="$SCRIPT_DIR/fpgrowth/fpgrowth/src/fpgrowth"
    OUTPUT_DIR="$SCRIPT_DIR/output_q1_2"

    if [ -x "$APRIORI_EXEC" ] && [ -x "$FP_EXEC" ]; then
        bash "$SCRIPT_DIR/q1_1.sh" "$APRIORI_EXEC" "$FP_EXEC" "$OUT_DATASET" "$OUTPUT_DIR" || \
            echo "Warning: q1_1.sh failed on generated dataset."
    else
        echo "Note: Apriori/FP-Growth executables not found; skipping Task-1 rerun."
    fi
fi
