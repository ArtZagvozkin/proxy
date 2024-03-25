#!/usr/bin/python3
#Artem Zagvozkin

unique_sites = set()
files_to_merge = ["src/web_sites_successful_1.txt", "src/web_sites_successful_2.txt"]
dst_file = "src/merged_web_sites.txt"

for file_path in files_to_merge:
    with open(file_path, "r") as file:
        sites = set(file.read().splitlines())
        unique_sites.update(sites)

with open(dst_file, "w") as merged_file:
    for site in unique_sites:
        merged_file.write(site + "\n")
