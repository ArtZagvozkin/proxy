#!/usr/bin/python3
#Artem Zagvozkin

import concurrent.futures
import requests

num_of_thread=25
proxies = {"https" : "http://user0001:user0001@95.164.7.8:33128"}
src_file = "src/test.csv"
log = "src/data.log"

time_spent = 0
num_of_responses = 1
successful_responses = 0

def check_site(site):
    global time_spent
    global num_of_responses
    global successful_responses

    site = site.strip()
    num_of_responses+=1

    try:
        response = requests.get(site, proxies=proxies)
        # print(f"URL: {site}, Response time: {response.elapsed.total_seconds()} sec., Status: {response.status_code}")

        time_spent+=response.elapsed.total_seconds()
        successful_responses+=1
    except requests.RequestException as e:
        print(f"Error: {site}: {e}")

with open(src_file, "r") as file:
    sites = file.readlines()



with concurrent.futures.ThreadPoolExecutor(max_workers=num_of_thread) as executor:
    executor.map(check_site, sites)


print("-"*20)
print(f"port: 33001")
print(f"Time spent: {time_spent:.2f} sec.")
print(f"Time per request: {time_spent/num_of_responses:.2f} sec.")
print(f"Successful requests: {successful_responses/num_of_responses*100}%")
