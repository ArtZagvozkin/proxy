#!/usr/bin/python3
#Artem Zagvozkin

import requests
import sys
import time

proxies = {"https" : "http://user0001:user0001@127.0.0.1:33128"}
src_file = "src/web_sites_all.csv"

if len(sys.argv) > 1:
    src_file = sys.argv[1]

with open(src_file, 'r', encoding='utf-8') as file:
    while True:
        line = file.readline()
        if not line:
            file.close()
            break

        url = f"https://{line.strip()}/"
        try:
            response = requests.get(url, proxies=proxies)
            print("true: " + url)
        except:
            print("false: " + url)

        time.sleep(0.5)
