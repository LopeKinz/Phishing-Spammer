require 'uri'
require 'net/http'
require 'json'
require 'time'

# Set your VirusTotal API key
API_KEY = "YOUR_VIRUSTOTAL_API_KEY"

# API endpoint for URL scanning
SCAN_URL = URI("https://www.virustotal.com/api/v3/urls")

# Database file name
DATABASE_FILE = "database.json"

# IP geolocation API endpoint
IP_API_URL = "https://ipapi.co/{}/json"

# Function to scan a URL using VirusTotal API
def scan_url(url)
    http = Net::HTTP.new(SCAN_URL.host, SCAN_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(SCAN_URL)
    request["x-apikey"] = API_KEY
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({ "url" => url })

    response = http.request(request)
    JSON.parse(response.body)
end

# Function to get IP address details
def get_ip_details(ip)
    response = Net::HTTP.get_response(URI.parse(IP_API_URL.format(ip)))
    JSON.parse(response.body)
end

# Function to collect data from phishing websites
def collect_data(url)    
    # Get the current date and time
    detected_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    
    # Get the IP address of the website
    parsed_url = URI.parse(url)
    ip_address = Socket.gethostbyname(parsed_url.host)
    
    # Get IP address details using IP geolocation API
    ip_details = get_ip_details(ip_address)
    
    {
        "url" => url,
        "detected_at" => detected_at,
        "ip_address" => ip_address,
        "ip_details" => ip_details
    }
end

# Function to save data to database.json
def save_to_database(data)
    File.open(DATABASE_FILE, "a") do |file|
        file.puts(JSON.dump(data))
    end
end

# Main program loop
loop do
    # Get user input
    print "Enter a URL to check for phishing (or 'q' to quit): "
    url = gets.chomp
    
    # Check if user wants to quit
    break if url.downcase == "q"
    
    # Validate the URL
    parsed_url = URI.parse(url)
    if !(parsed_url.scheme && parsed_url.host)
        puts "Invalid URL! Please enter a valid URL."
        next
    end
    
    # Scan the URL using VirusTotal API
    response = scan_url(url)
    
    # Check if scan was successful
    if response["data"]
        data_id = response["data"]["id"]
        puts "URL submitted for scanning. Scan ID: #{data_id}"
        
        # Wait for the scan to complete
        loop do
            sleep(5)  # Wait for 5 seconds before checking the scan status
            response = Net::HTTP.get_response("#{SCAN_URL}/#{data_id}", "x-apikey" => API_KEY)
            scan_result = JSON.parse(response.body)
            
            break if scan_result["data"]["attributes"]["status"] == "completed"
        end
        
        # Check if the URL is phishing
        if scan_result["data"]["attributes"]["last_analysis_stats"]["malicious"] > 0
            puts "Phishing URL detected!"
            
            # Collect data from the phishing website
            collected_data = collect_data(url)
            
            # Save data to database.json
            save_to_database(collected_data)
        else
            puts "URL is safe."
        end
    else
        puts "Error occurred while scanning the URL. Please try again."
    end
end
