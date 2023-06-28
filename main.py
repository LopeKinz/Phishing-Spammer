import requests
import json
import time
from urllib.parse import urlparse

# Set your VirusTotal API key
API_KEY = "YOUR_VIRUSTOTAL_API_KEY"

# API endpoint for URL scanning
SCAN_URL = "https://www.virustotal.com/api/v3/urls"

# Database file name
DATABASE_FILE = "database.json"

# IP geolocation API endpoint
IP_API_URL = "https://ipapi.co/{}/json"

# Function to scan a URL using VirusTotal API
def scan_url(url):
    headers = {
        "x-apikey": API_KEY,
        "Content-Type": "application/json",
    }
    data = {
        "url": url
    }
    response = requests.post(SCAN_URL, headers=headers, data=json.dumps(data))
    return response.json()

# Function to get IP address details
def get_ip_details(ip):
    response = requests.get(IP_API_URL.format(ip))
    return response.json()

# Function to collect data from phishing websites
def collect_data(url):
    # Add your code here to collect data from phishing websites
    # and store it in the desired format
    
    # For example, you can extract relevant information using libraries like BeautifulSoup
    
    # Get the current date and time
    detected_at = time.strftime("%Y-%m-%d %H:%M:%S")
    
    # Get the IP address of the website
    parsed_url = urlparse(url)
    ip_address = socket.gethostbyname(parsed_url.netloc)
    
    # Get IP address details using IP geolocation API
    ip_details = get_ip_details(ip_address)
    
    return {
        "url": url,
        "detected_at": detected_at,
        "ip_address": ip_address,
        "ip_details": ip_details
    }

# Function to save data to database.json
def save_to_database(data):
    with open(DATABASE_FILE, "a") as file:
        json.dump(data, file)
        file.write("\n")

# Main program loop
while True:
    # Get user input
    url = input("Enter a URL to check for phishing (or 'q' to quit): ")
    
    # Check if user wants to quit
    if url.lower() == "q":
        break
    
    # Validate the URL
    parsed_url = urlparse(url)
    if not (parsed_url.scheme and parsed_url.netloc):
        print("Invalid URL! Please enter a valid URL.")
        continue
    
    # Scan the URL using VirusTotal API
    response = scan_url(url)
    
    # Check if scan was successful
    if "data" in response:
        data_id = response["data"]["id"]
        print(f"URL submitted for scanning. Scan ID: {data_id}")
        
        # Wait for the scan to complete
        while True:
            time.sleep(5)  # Wait for 5 seconds before checking the scan status
            response = requests.get(f"{SCAN_URL}/{data_id}", headers={"x-apikey": API_KEY})
            scan_result = response.json()
            
            if scan_result["data"]["attributes"]["status"] == "completed":
                break
        
        # Check if the URL is phishing
        if scan_result["data"]["attributes"]["last_analysis_stats"]["malicious"] > 0:
            print("Phishing URL detected!")
            
            # Collect data from the phishing website
            collected_data = collect_data(url)
            
            # Save data to database.json
            save_to_database(collected_data)
        else:
            print("URL is safe.")
    else:
        print("Error occurred while scanning the URL. Please try again.")
