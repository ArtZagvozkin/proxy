#!/usr/bin/python3
#Artem Zagvozkin

import concurrent.futures
import requests

num_of_thread=25
proxies = {"https" : "http://user0001:user0001@127.0.0.1:33128"}
# proxies = {"https" : "http://127.0.0.1:33128"}
src_file = "src/test.csv"
dst_file = "src/web_sites_successful.txt"

def check_site(site):
    site = site.strip()
    # site = f"https://{site.strip()}/"
    try:
        response = requests.get(site, proxies=proxies)
        # response = requests.get(site)
        if response.status_code == 200 and response.elapsed.total_seconds() < 1.0:
            print(f"URL: {site}, Response time: {response.elapsed.total_seconds()} sec., Status: {response.status_code}")
            with open(dst_file, "a") as f:
                f.write(site + "\n")
    except requests.RequestException as e:
        print(f"Error: {site}: {e}")

with open(src_file, "r") as file:
    sites = file.readlines()

with concurrent.futures.ThreadPoolExecutor(max_workers=num_of_thread) as executor:
    executor.map(check_site, sites)

print("All sites are checked")
