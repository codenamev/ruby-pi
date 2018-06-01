#!/usr/bin/env ruby

require "rpi_gpio"

LED_PINS = [17, 18, 27, 22, 23, 24, 25, 4]

puts "========================================"
puts "|                8 LEDs                |"
puts "|    ------------------------------    |"
puts "|         LED0 connect to GPIO0        |"
puts "|         LED1 connect to GPIO1        |"
puts "|         LED2 connect to GPIO2        |"
puts "|         LED3 connect to GPIO3        |"
puts "|         LED4 connect to GPIO4        |"
puts "|         LED5 connect to GPIO5        |"
puts "|         LED6 connect to GPIO6        |"
puts "|         LED7 connect to GPIO7        |"
puts "|                                      |"
puts "|            Flow LED effect           |"
puts "|                                      |"
puts "|                            codenamev |"
puts "========================================\n"
puts "Program is running..."
puts "Please press Ctrl+C to end the program..."
puts "Press Enter to begin"
raw_input = STDIN.gets.chomp

@led_status_matrix = {}
LED_PINS.each { |pin| @led_status_matrix[pin] = "-" }

# Set the GPIO modes to BCM Numbering
RPi::GPIO.set_numbering :bcm
# Set all LedPin's mode to output, and initial level to High(3.3v)
RPi::GPIO.setup LED_PINS, as: :output, initialize: :high

def inline_puts(output)
  STDOUT.write "\r#{output}"
  STDOUT.flush
end

at_exit do
  # Turn off all LEDs
  RPi::GPIO.set_high LED_PINS
  # Release resource
  RPi::GPIO.clean_up
end

def flash_led(pin_number)
  RPi::GPIO.set_low pin_number
  @led_status_matrix[pin_number] = "0" # Show the LED is on
  inline_puts @led_status_matrix.values.join('')
  sleep 0.1
  RPi::GPIO.set_high pin_number
  @led_status_matrix[pin_number] = "-" # Show the LED is off
end

begin
  loop do
    # Turn LED off from left to right
    LED_PINS.each do |pin_number|
      flash_led(pin_number)
    end

    # Turn LED off from right to left
    LED_PINS.reverse.each do |pin_number|
      flash_led(pin_number)
    end
  end
rescue Interrupt, SignalException
  exit
end
