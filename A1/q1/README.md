# Question 1: Frequent Itemset Mining

## Compilation

To compile the Apriori and FP-Growth algorithms from source:

```bash
cd A1/q1
bash compile.sh
```

This will compile both algorithms and create executables in their respective directories.

## Task 1: Algorithm Comparison

Run the comparison on the webdocs dataset:
NOTE: download dataset from http://fimi.uantwerpen.be/data/webdocs.dat.gz (Too large to push on github sed)

### Exact commands (from repo layout)
Assuming you are in:
`/home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1`

1) Unzip dataset (if needed):
```bash
gunzip /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/webdocs.dat.gz
```

2) Run Task 1:
```bash
bash q1_1.sh \
  /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/apriori/apriori/src/apriori \
  /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/fpgrowth/fpgrowth/src/fpgrowth \
  /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/webdocs.dat \
  /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/output
```

```bash
bash q1_1.sh <path_to_apriori> <path_to_fpgrowth> <path_to_dataset> <output_dir>
```

Example:
```bash
bash q1_1.sh \
    apriori/apriori/src/apriori \
    fpgrowth/fpgrowth/src/fpgrowth \
    /path/to/webdocs.dat \
    ./output
```

This will:
- Run both algorithms at support thresholds: 5%, 10%, 25%, 50%, 90%
- Save outputs to files: ap5, ap10, ap25, ap50, ap90, fp5, fp10, fp25, fp50, fp90
- Generate plot.png showing runtime comparison

## Task 2: Constructed Dataset + Re-run (Q1.2)

What the assignment expects:
- Generate ~15,000 *unique* transactions using only the provided universal itemset.
- Do **not** force runtime behavior by duplicating identical transactions.
- Re-run Task 1 on the constructed dataset and generate a new plot.
- In the report, compare the runtime trends vs. the original dataset.

### Step 1: Generate the dataset

```bash
bash q1_2.sh <universal_itemset> <num_transactions>
```

Examples:
```bash
# If itemset is provided inline:
bash q1_2.sh "A B C D E F G H I J" 15000

# If itemset is in a file (one item per line or whitespace-separated):
bash q1_2.sh /absolute/path/to/itemset.txt 15000
```

### Exact commands (recommended)
1) Create a 100-item universe file:
```bash
python3 - <<'PY'
items = [f"I{i}" for i in range(1, 101)]
with open("/home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/itemset.txt", "w") as f:
    f.write("\n".join(items))
print("Wrote itemset.txt with 100 items")
PY
```

2) Generate 15,000 transactions:
```bash
bash q1_2.sh /home/abhaas/Desktop/COURSES/COL761/BitBlasting/A1/q1/itemset.txt 15000
```

Or auto-generate an itemset inside q1_2.sh:
```bash
bash q1_2.sh AUTO 15000
# or for a different universe size:
bash q1_2.sh AUTO:200 15000
```

This creates `generated_transactions.dat` in the current `q1` directory.

### Step 2: Re-run Task 1 on the constructed dataset

```bash
bash q1_1.sh \
    apriori/apriori/src/apriori \
    fpgrowth/fpgrowth/src/fpgrowth \
    ./generated_transactions.dat \
    ./output_q1_2
```

This produces the same set of output files and a new `plot.png` for the constructed dataset.

### Optional: single command (only after compilation)

You can also let `q1_2.sh` run Task 1 immediately by setting an environment flag:
```bash
RUN_Q1_1=1 bash q1_2.sh "<items...>" 15000
```

## Report (q1.pdf)

Include:
- Runtime plots for both datasets.
- Qualitative comparison of the trends.
- Explanation based on item/transaction distributions.

## Files

- `compile.sh`: Compiles Apriori and FP-Growth
- `q1_1.sh`: Runs Task 1 pipeline
- `q1_2.sh`: Generates dataset for Task 2 (and optionally re-runs Task 1)
- `generate_transactions.py`: Dataset generator used by q1_2.sh
- `plot_results.py`: Python script for plotting
