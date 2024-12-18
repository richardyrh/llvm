
import sys
import os
import glob
import csv

from asm_parser import parse_asm
from stats import get_statistics_strs, get_statistics

def write_csv(results):
    csv_filename = "results.csv"
    stat_names = get_statistics_strs()
    headers = ["name"] + ["baseline_" + stat for stat in stat_names] + ["modified_" + stat for stat in stat_names]
    with open(csv_filename, mode="w", newline="") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(headers)
    
        for result in results:
            writer.writerow(result)

def evaluate_files(file1, file2, files3):
    stats_file1 = get_statistics(parse_asm(file1))
    stats_file2 = get_statistics(parse_asm(file2))
    stats_file3 = get_statistics(parse_asm(file3))
    print(file1 + ": ")
    print(stats_file1)
    print(file2 + ": ")
    print(stats_file2)
    print(file3 + ": ")
    print(stats_file3)

def evaluate_all(directory):
    baseline_files = glob.glob(os.path.join(directory, "*-baseline.s"))
    stats = []
    for baseline_file in baseline_files:
        base_name = baseline_file.replace("-baseline.s", "")
        modified_file = base_name + "-modified.s"
        
        if os.path.exists(modified_file):
           stats_baseline = get_statistics(parse_asm(baseline_file))
           stats_modified = get_statistics(parse_asm(modified_file))
           stats.append([os.path.basename(base_name)] + stats_baseline + stats_modified)
        else:
            assert False, (f"Modified file for {baseline_file} not found.")
    
    return stats

if __name__ == "__main__":
    if len(sys.argv) == 1:
        stats = evaluate_all('./build')
        write_csv(stats)
    elif len(sys.argv) == 4:
        stats = evaluate_files(sys.argv[1], sys.argv[2], sys.argv[3])




