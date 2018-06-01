#!/usr/bin/env ruby

require "rpi_gpio"

# Set #17 as LED pin
LED_PIN_NUMBER = 17

puts "========================================"
puts "|              Blink LED               |"
puts "|    ------------------------------    |"
puts "|         LED connect to GPIO0         |"
puts "|                                      |"
puts "|        LED will Blink at 500ms       |"
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
# and initial level to High(3.3v)
RPi::GPIO.setup LED_PIN_NUMBER, as: :output, initialize: :high

# Define a destroy function for clean up everything after
# the script finished
at_exit do
  inline_puts "Cleaning up..."
  # Turn off LED
  RPi::GPIO.set_high LED_PIN_NUMBER
  # Release resource
  RPi::GPIO.clean_up
  exit
end

# Define a main function for main process
loop do
  inline_puts "...LED ON"
  # Turn on LED
  RPi::GPIO.set_low LED_PIN_NUMBER
  sleep 0.5
  inline_puts "LED OFF..."
  # Turn off LED
  RPi::GPIO.set_high LED_PIN_NUMBER
  sleep 0.5
rescue Interrupt, SignalException
  exit
end
