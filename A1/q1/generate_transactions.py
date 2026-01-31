#!/usr/bin/env python3
"""
Generate a transactional dataset for Q1 Task-2.

Usage:
  python3 generate_transactions.py <universal_itemset> <num_transactions> <output_file>

<universal_itemset> can be:
  - a comma/space-separated list of items, OR
  - a path to a file containing items (one per line or whitespace-separated)
"""

import sys
import os
import random
from pathlib import Path


def load_items(spec):
    path = Path(spec)
    if path.exists():
        text = path.read_text()
        tokens = text.replace(",", " ").split()
    else:
        tokens = spec.replace(",", " ").split()

    items = []
    seen = set()
    for t in tokens:
        if t not in seen:
            seen.add(t)
            items.append(t)
    return items


def build_clusters(items, rng):
    n = len(items)
    if n < 4:
        return [], []

    k = max(3, min(10, n // 5))
    clusters = []
    for _ in range(k):
        min_sz = 3
        max_sz = min(12, n)
        if max_sz < min_sz:
            max_sz = min_sz
        sz = rng.randint(min_sz, max_sz)
        clusters.append(rng.sample(items, sz))

    weights = [1.0 / (i + 1) for i in range(len(clusters))]
    return clusters, weights


def choose_length(n_items, rng):
    if n_items <= 5:
        return max(2, n_items)
    r = rng.random()
    if r < 0.10:
        return min(n_items, rng.randint(3, 5))
    if r < 0.70:
        return min(n_items, rng.randint(6, 12))
    return min(n_items, rng.randint(12, 20))


def generate_transaction(items, clusters, cluster_weights, item_weights, rng):
    n = len(items)
    length = choose_length(n, rng)

    chosen = set()
    if clusters:
        cluster = rng.choices(clusters, weights=cluster_weights, k=1)[0]
        min_pick = 2 if len(cluster) >= 2 else 1
        max_pick = max(min_pick, min(len(cluster), max(2, length // 2)))
        pick = rng.randint(min_pick, max_pick)
        chosen.update(rng.sample(cluster, pick))

    while len(chosen) < length:
        item = rng.choices(items, weights=item_weights, k=1)[0]
        chosen.add(item)

    # Preserve item order as per universe
    return [it for it in items if it in chosen]


def main():
    if len(sys.argv) != 4:
        print("Usage: python3 generate_transactions.py <universal_itemset> <num_transactions> <output_file>")
        sys.exit(1)

    item_spec = sys.argv[1]
    try:
        num_tx = int(sys.argv[2])
    except ValueError:
        print("Error: <num_transactions> must be an integer.")
        sys.exit(1)
    out_path = sys.argv[3]

    items = load_items(item_spec)
    if not items:
        print("Error: universal_itemset is empty.")
        sys.exit(1)

    rng = random.Random(42)
    clusters, cluster_weights = build_clusters(items, rng)

    # Zipf-like weights to create skewed item frequencies
    alpha = 1.1
    item_weights = [1.0 / ((i + 1) ** alpha) for i in range(len(items))]

    seen = set()
    transactions = []
    max_attempts = num_tx * 30
    attempts = 0

    while len(transactions) < num_tx and attempts < max_attempts:
        attempts += 1
        tx = generate_transaction(items, clusters, cluster_weights, item_weights, rng)
        key = tuple(tx)
        if key in seen:
            continue
        seen.add(key)
        transactions.append(tx)

    if len(transactions) < num_tx:
        print(f"Warning: generated {len(transactions)} unique transactions out of requested {num_tx}.")

    with open(out_path, "w") as f:
        for tx in transactions:
            f.write(" ".join(tx) + "\n")

    print(f"Wrote {len(transactions)} transactions to {out_path}")


if __name__ == "__main__":
    main()
