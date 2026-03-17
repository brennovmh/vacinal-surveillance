#!/usr/bin/env python3

import argparse
import csv
import os
from collections import Counter, defaultdict

def read_tsv(path):
    with open(path) as f:
        return list(csv.DictReader(f, delimiter="\t"))

def write_general_stats(summary_rows, outdir):
    out = os.path.join(outdir, "vaccine_classification_mqc.tsv")
    with open(out, "w", newline="") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow([
            "Sample",
            "Classification",
            "Vaccine_score"
        ])
        for row in summary_rows:
            writer.writerow([
                row["sample"],
                row["classification"],
                row["vaccine_score"]
            ])

def write_status_table(summary_rows, outdir):
    out = os.path.join(outdir, "vaccine_status_overview_mqc.yaml")
    counts = Counter(row["classification"] for row in summary_rows)

    with open(out, "w") as f:
        f.write("id: 'vaccine_status_overview'\n")
        f.write("section_name: 'Classificação vacinal'\n")
        f.write("description: 'Resumo das amostras classificadas quanto à origem vacinal.'\n")
        f.write("plot_type: 'bargraph'\n")
        f.write("pconfig:\n")
        f.write("  id: 'vaccine_status_overview_plot'\n")
        f.write("  title: 'Distribuição das classificações'\n")
        f.write("  ylab: 'Número de amostras'\n")
        f.write("data:\n")
        f.write(f"  VACCINE_LIKE: {counts.get('VACCINE_LIKE', 0)}\n")
        f.write(f"  NON_VACCINE: {counts.get('NON_VACCINE', 0)}\n")
        f.write(f"  INCONCLUSIVE: {counts.get('INCONCLUSIVE', 0)}\n")

def write_marker_heatmap(details_rows, outdir):
    samples = sorted({r["sample"] for r in details_rows})
    positions = sorted({int(r["position"]) for r in details_rows})

    status_to_value = {
        "PRESENT": 1,
        "ABSENT": 0,
        "LOW_COVERAGE": -1
    }

    matrix = defaultdict(dict)
    for r in details_rows:
        sample = r["sample"]
        pos = r["position"]
        matrix[sample][pos] = status_to_value.get(r["status"], -1)

    out = os.path.join(outdir, "marker_heatmap_mqc.tsv")
    with open(out, "w", newline="") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow(["Sample"] + [str(p) for p in positions])
        for sample in samples:
            writer.writerow([sample] + [matrix[sample].get(str(p), -1) for p in positions])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--summary", required=True)
    parser.add_argument("--details", required=True)
    parser.add_argument("--outdir", required=True)
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    summary_rows = read_tsv(args.summary)
    details_rows = read_tsv(args.details)

    write_general_stats(summary_rows, args.outdir)
    write_status_table(summary_rows, args.outdir)
    write_marker_heatmap(details_rows, args.outdir)

if __name__ == "__main__":
    main()
