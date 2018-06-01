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
puts "|         Binary clock counter         |"
puts "|                                      |"
puts "|                            codenamev |"
puts "========================================\n"
puts "Program is running..."
puts "Please press Ctrl+C to end the program..."
puts "Press Enter to begin"
raw_input = STDIN.gets.chomp

@pin_binary_map = {}
max_count = 1
LED_PINS.each_with_index do |pin, index|
  current_binary_number = (2 ** index)
  @pin_binary_map[pin] = current_binary_number
  max_count += current_binary_number
end

# Set the GPIO modes to BCM Numbering
RPi::GPIO.set_numbering :bcm
# Set all LedPin's mode to output, and initial level to High(3.3v)
RPi::GPIO.setup LED_PINS, as: :output, initialize: :high

at_exit do
  # Turn off all LEDs
  RPi::GPIO.set_high LED_PINS
  # Release resource
  RPi::GPIO.clean_up
  STDOUT.write "\r"
end

count = 0
puts "Now counting to #{max_count}"
begin
  while count < max_count do
    count += 1
    remaining = count
    while remaining > 0 do
      @pin_binary_map.keys.reverse.each do |pin_number|
        binary_number = @pin_binary_map[pin_number]
        if binary_number > remaining
          RPi::GPIO.set_high pin_number
        else
          RPi::GPIO.set_low pin_number
          remaining -= binary_number
        end
      end
    end
    # Announce here to account for delays in setting pin levels
    STDOUT.write "\r#{count}..."
    STDOUT.flush
    sleep 1
  end
  exit
rescue Interrupt, SignalException
  exit
end
