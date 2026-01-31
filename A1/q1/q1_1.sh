#!/bin/bash

# Usage: bash q1_1.sh <path_apriori_executable> <path_fp_executable> <path_dataset> <path_out>

if [ "$#" -ne 4 ]; then
    echo "Usage: bash q1_1.sh <path_apriori_executable> <path_fp_executable> <path_dataset> <path_out>"
    exit 1
fi

APRIORI_EXEC="$1"
FP_EXEC="$2"
DATASET="$3"
OUTPUT_DIR="$4"

if [ ! -x "$APRIORI_EXEC" ]; then
    echo "Error: Apriori executable not found or not executable: $APRIORI_EXEC"
    exit 1
fi

if [ ! -x "$FP_EXEC" ]; then
    echo "Error: FP-Growth executable not found or not executable: $FP_EXEC"
    exit 1
fi

if [ ! -f "$DATASET" ]; then
    echo "Error: Dataset not found: $DATASET"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Support thresholds (in percentage)
# Default: 10 25 50 90
# Override by setting THRESHOLDS env, e.g.:
#   THRESHOLDS="10" bash q1_1.sh ...
if [ -n "$THRESHOLDS" ]; then
    read -r -a THRESHOLDS_ARR <<< "$THRESHOLDS"
    THRESHOLDS=("${THRESHOLDS_ARR[@]}")
else
    THRESHOLDS=(10 25 50 90)
fi

# Arrays to store runtimes
declare -a APRIORI_TIMES
declare -a FP_TIMES

echo "Running Apriori and FP-Growth at different support thresholds..."

# Helper: check if log indicates no frequent items
no_frequent_items() {
    local log_file="$1"
    if [ -f "$log_file" ]; then
        grep -qiE "no \\(frequent\\) items found|no frequent items found" "$log_file"
        return $?
    fi
    return 1
}

# Run Apriori at different thresholds
for threshold in "${THRESHOLDS[@]}"; do
    echo "Running Apriori at ${threshold}% support..."
    
    # Time the execution
    START=$(python3 -c 'import time; print(time.time())')
    
    LOG_FILE="$OUTPUT_DIR/ap${threshold}.log"
    "$APRIORI_EXEC" -s${threshold} "$DATASET" "$OUTPUT_DIR/ap${threshold}" > "$LOG_FILE" 2>&1
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        if no_frequent_items "$LOG_FILE"; then
            echo "  Warning: Apriori found no frequent items at ${threshold}% (continuing)"
            : > "$OUTPUT_DIR/ap${threshold}"
        else
            echo "  Error: Apriori failed at ${threshold}% (see $LOG_FILE)"
            exit 1
        fi
    fi
    if [ ! -s "$OUTPUT_DIR/ap${threshold}" ]; then
        if no_frequent_items "$LOG_FILE"; then
            : > "$OUTPUT_DIR/ap${threshold}"
        else
            echo "  Error: Apriori output missing or empty at ${threshold}%"
            exit 1
        fi
    fi
    
    END=$(python3 -c 'import time; print(time.time())')
    RUNTIME=$(python3 -c "print($END - $START)")
    
    APRIORI_TIMES+=("$RUNTIME")
    echo "  Apriori ${threshold}%: ${RUNTIME}s"
done

# Run FP-Growth at different thresholds
for threshold in "${THRESHOLDS[@]}"; do
    echo "Running FP-Growth at ${threshold}% support..."
    
    # Time the execution
    START=$(python3 -c 'import time; print(time.time())')
    
    LOG_FILE="$OUTPUT_DIR/fp${threshold}.log"
    "$FP_EXEC" -s${threshold} "$DATASET" "$OUTPUT_DIR/fp${threshold}" > "$LOG_FILE" 2>&1
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        if no_frequent_items "$LOG_FILE"; then
            echo "  Warning: FP-Growth found no frequent items at ${threshold}% (continuing)"
            : > "$OUTPUT_DIR/fp${threshold}"
        else
            echo "  Error: FP-Growth failed at ${threshold}% (see $LOG_FILE)"
            exit 1
        fi
    fi
    if [ ! -s "$OUTPUT_DIR/fp${threshold}" ]; then
        if no_frequent_items "$LOG_FILE"; then
            : > "$OUTPUT_DIR/fp${threshold}"
        else
            echo "  Error: FP-Growth output missing or empty at ${threshold}%"
            exit 1
        fi
    fi
    
    END=$(python3 -c 'import time; print(time.time())')
    RUNTIME=$(python3 -c "print($END - $START)")
    
    FP_TIMES+=("$RUNTIME")
    echo "  FP-Growth ${threshold}%: ${RUNTIME}s"
done

# Save timing results to a file for Python plotting script
RESULTS_FILE="$OUTPUT_DIR/results.txt"
echo "thresholds,apriori_times,fp_times" > "$RESULTS_FILE"

for i in "${!THRESHOLDS[@]}"; do
    echo "${THRESHOLDS[$i]},${APRIORI_TIMES[$i]},${FP_TIMES[$i]}" >> "$RESULTS_FILE"
done

# Generate the plot using Python
echo "Generating plot..."
python3 plot_results.py "$RESULTS_FILE" "$OUTPUT_DIR/plot.png"

echo "Done! Results saved to $OUTPUT_DIR"
