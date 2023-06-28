import pyautogui
import random
import time
import keyboard

# Hotkey to start capturing positions
START_HOTKEY = "ctrl+alt+s"

# Hotkey to fill in values and submit
FILL_HOTKEY = "ctrl+alt+f"

# Hotkey to stop the script
STOP_HOTKEY = "ctrl+alt+x"

# Positions dictionary
positions = {
    "email_box": None,
    "password_box": None,
    "submit_button": None
}

# Function to capture mouse position
def capture_position(position_key):
    print(f"Move your mouse to the {position_key} and press {START_HOTKEY} to capture the position.")
    while True:
        if keyboard.is_pressed(START_HOTKEY):
            position = pyautogui.position()
            positions[position_key] = (position.x, position.y)
            print(f"{position_key} position captured!")
            break

# Function to fill in email and password fields with random values
def fill_values_and_submit():
    email = "example@example.com"  # Replace with your desired email format or generate randomly
    password = "examplepassword"  # Replace with your desired password format or generate randomly
    
    print("Filling in values and submitting...")
    
    # Move mouse to email box position and click
    email_box_position = positions["email_box"]
    pyautogui.moveTo(email_box_position[0], email_box_position[1], duration=0.5)
    pyautogui.click()
    
    # Fill in email field
    pyautogui.typewrite(email, interval=0.1)
    
    # Move mouse to password box position and click
    password_box_position = positions["password_box"]
    pyautogui.moveTo(password_box_position[0], password_box_position[1], duration=0.5)
    pyautogui.click()
    
    # Fill in password field
    pyautogui.typewrite(password, interval=0.1)
    
    # Move mouse to submit button position and click
    submit_button_position = positions["submit_button"]
    pyautogui.moveTo(submit_button_position[0], submit_button_position[1], duration=0.5)
    pyautogui.click()
    
    print("Values filled and submitted!")
    
    # Wait for 3 seconds
    time.sleep(3)
    
    # Go back a page in the browser
    keyboard.press_and_release('backspace')

# Function to handle hotkey events
def hotkey_handler():
    if keyboard.is_pressed(STOP_HOTKEY):
        return False  # Stop the script
    
    if keyboard.is_pressed(START_HOTKEY):
        capture_position("email_box")
    
    if keyboard.is_pressed(FILL_HOTKEY):
        fill_values_and_submit()
    
    return True  # Continue listening for hotkey events

# Main program loop
print("Press Ctrl+Alt+X to stop the script.")

while True:
    if not hotkey_handler():
        break
