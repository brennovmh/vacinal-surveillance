#!/usr/bin/env python3

import argparse
import csv

def merge_tsv(files, output_path):
    header = None
    rows = []

    for path in files:
        with open(path) as f:
            reader = csv.reader(f, delimiter="\t")
            current_header = next(reader)
            if header is None:
                header = current_header
            for row in reader:
                rows.append(row)

    with open(output_path, "w", newline="") as out:
        writer = csv.writer(out, delimiter="\t")
        writer.writerow(header)
        writer.writerows(rows)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--summaries", nargs="+", required=True)
    parser.add_argument("--details", nargs="+", required=True)
    parser.add_argument("--out-summary", required=True)
    parser.add_argument("--out-details", required=True)
    args = parser.parse_args()

    merge_tsv(args.summaries, args.out_summary)
    merge_tsv(args.details, args.out_details)

if __name__ == "__main__":
    main()
