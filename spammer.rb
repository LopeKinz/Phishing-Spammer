require 'io/console'
require 'io/wait'
require 'io/console/size'
require 'xdotool'

# Hotkey to start capturing positions
START_HOTKEY = "ctrl+alt+s"

# Hotkey to fill in values and submit
FILL_HOTKEY = "ctrl+alt+f"

# Hotkey to stop the script
STOP_HOTKEY = "ctrl+alt+x"

# Positions hash
positions = {
  "email_box" => nil,
  "password_box" => nil,
  "submit_button" => nil
}

# Function to capture mouse position
def capture_position(position_key)
  puts "Move your mouse to the #{position_key} and press #{START_HOTKEY} to capture the position."
  loop do
    break if IO.console.iflush && STDIN.getch(0.01) == START_HOTKEY
    sleep(0.01)
  end
  position = XDoTool.get_mouse_location
  positions[position_key] = [position.x, position.y]
  puts "#{position_key} position captured!"
end

# Function to fill in email and password fields with random values
def fill_values_and_submit
  email = "example@example.com"  # Replace with your desired email format or generate randomly
  password = "examplepassword"  # Replace with your desired password format or generate randomly
  
  puts "Filling in values and submitting..."
  
  # Move mouse to email box position and click
  email_box_position = positions["email_box"]
  XDoTool.move_mouse_to(email_box_position[0], email_box_position[1])
  XDoTool.click(1)
  
  # Fill in email field
  XDoTool.type(email)
  
  # Move mouse to password box position and click
  password_box_position = positions["password_box"]
  XDoTool.move_mouse_to(password_box_position[0], password_box_position[1])
  XDoTool.click(1)
  
  # Fill in password field
  XDoTool.type(password)
  
  # Move mouse to submit button position and click
  submit_button_position = positions["submit_button"]
  XDoTool.move_mouse_to(submit_button_position[0], submit_button_position[1])
  XDoTool.click(1)
  
  puts "Values filled and submitted!"
  
  # Wait for 3 seconds
  sleep(3)
  
  # Go back a page in the browser
  XDoTool.send_key('BackSpace')
end

# Function to handle hotkey events
def hotkey_handler
  stop_requested = false
  
  if XDoTool.hotkey?(STOP_HOTKEY)
    stop_requested = true
  end
  
  if XDoTool.hotkey?(START_HOTKEY)
    capture_position("email_box")
  end
  
  if XDoTool.hotkey?(FILL_HOTKEY)
    fill_values_and_submit
  end
  
  stop_requested
end

# Main program loop
puts "Press Ctrl+Alt+X to stop the script."

loop do
  break if hotkey_handler
end
