#!/usr/bin/env python3

import argparse
import csv
import gzip
import os

def read_markers(path):
    markers = []
    with open(path) as f:
        reader = csv.DictReader(f, delimiter="\t")
        for row in reader:
            row["position"] = int(row["position"])
            row["required"] = str(row["required"]).lower() == "true"
            markers.append(row)
    return markers

def read_vcf_positions(vcf_path):
    found = {}
    opener = gzip.open if vcf_path.endswith(".gz") else open
    with opener(vcf_path, "rt") as f:
        for line in f:
            if line.startswith("#"):
                continue
            cols = line.strip().split("\t")
            pos = int(cols[1])
            ref = cols[3]
            alt = cols[4].split(",")[0]
            found[pos] = (ref, alt)
    return found

def read_depth(depth_path):
    depth_map = {}
    with open(depth_path) as f:
        for line in f:
            chrom, pos, depth = line.strip().split("\t")
            depth_map[int(pos)] = int(depth)
    return depth_map

def classify(markers, variants, depth_map, min_depth):
    results = []
    required_ok = True
    required_testable = True

    for marker in markers:
        pos = marker["position"]
        expected_ref = marker["ref"]
        expected_alt = marker["alt"]
        required = marker["required"]

        depth = depth_map.get(pos, 0)
        if depth < min_depth:
            status = "LOW_COVERAGE"
            if required:
                required_testable = False
        else:
            if pos in variants and variants[pos] == (expected_ref, expected_alt):
                status = "PRESENT"
            else:
                status = "ABSENT"
                if required:
                    required_ok = False

        results.append({
            "position": pos,
            "ref": expected_ref,
            "alt": expected_alt,
            "depth": depth,
            "required": required,
            "status": status
        })

    if not required_testable:
        classification = "INCONCLUSIVE"
        interpretation = "Cobertura insuficiente em marcadores obrigatórios."
    elif required_ok:
        classification = "VACCINE_LIKE"
        interpretation = "Perfil compatível com origem vacinal pelos marcadores avaliados."
    else:
        classification = "NON_VACCINE"
        interpretation = "Perfil não compatível com origem vacinal pelos marcadores avaliados."

    return results, classification, interpretation

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sample", required=True)
    parser.add_argument("--consensus", required=False)
    parser.add_argument("--vcf", required=True)
    parser.add_argument("--depth", required=True)
    parser.add_argument("--markers", required=True)
    parser.add_argument("--min-depth", type=int, default=10)
    args = parser.parse_args()

    markers = read_markers(args.markers)
    variants = read_vcf_positions(args.vcf)
    depth_map = read_depth(args.depth)

    results, classification, interpretation = classify(
        markers, variants, depth_map, args.min_depth
    )

    per_sample_file = f"{args.sample}.classification.tsv"
    with open(per_sample_file, "w", newline="") as out:
        writer = csv.writer(out, delimiter="\t")
        writer.writerow(["sample", "position", "ref", "alt", "depth", "required", "status"])
        for r in results:
            writer.writerow([
                args.sample, r["position"], r["ref"], r["alt"],
                r["depth"], r["required"], r["status"]
            ])

    summary_file = "classification_summary.tsv"
    file_exists = os.path.exists(summary_file)

    with open(summary_file, "a", newline="") as out:
        writer = csv.writer(out, delimiter="\t")
        if not file_exists:
            writer.writerow(["sample", "classification", "interpretation"])
        writer.writerow([args.sample, classification, interpretation])

if __name__ == "__main__":
    main()
