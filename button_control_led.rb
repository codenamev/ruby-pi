#!/usr/bin/env ruby

require "rpi_gpio"

# Set #17 as LED pin
LED_PIN_NUMBER = 17
# Set #18 as button pin
BUTTON_PIN_NUMBER = 18

puts "========================================"
puts "|          Button control LED          |"
puts "|    ------------------------------    |"
puts "|         LED connect to GPIO0         |"
puts "|        Button connect to GPIO1       |"
puts "|                                      |"
puts "|   Press button to turn on/off LED.   |"
puts "|                                      |"
puts "|                            codenamev |"
puts "========================================\n"
puts "Program is running..."
puts "Please press Ctrl+C to end the program..."
puts "Press Enter to begin"
raw_input = STDIN.gets.chomp

def inline_puts(output)
  STDOUT.write "\r#{output}"
  STDOUT.flush
end

# Set the GPIO modes to BCM Numbering
RPi::GPIO.set_numbering :bcm
# Set LED_PIN_NUMBER's mode to output,
# and initial level to high (3.3v)
RPi::GPIO.setup LED_PIN_NUMBER, as: :output, initialize: :high
# Set BUTTON_PIN_NUMBER's mode to input,
# and pull up to high (3.3V)
RPi::GPIO.setup BUTTON_PIN_NUMBER, as: :input, pull: :up

# Clean up everything after the script finishes
at_exit do
  inline_puts "Cleaning up..."
  # Turn off LED
  RPi::GPIO.set_high LED_PIN_NUMBER
  # Release resource
  RPi::GPIO.clean_up
  exit
end

loop do
  if RPi::GPIO.high? BUTTON_PIN_NUMBER
    RPi::GPIO.set_high LED_PIN_NUMBER
  else
    RPi::GPIO.set_low LED_PIN_NUMBER
  end
rescue Interrupt, SignalException
  exit
end
