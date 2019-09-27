#!/usr/bin/env ruby

require "rpi_gpio"

# Set #18 as LED pin
LED_PIN = 18

puts "========================================"
puts "|              Breath LED              |"
puts "|    ------------------------------    |"
puts "|         LED connect to GPIO1         |"
puts "|                                      |"
puts "|            Make LED breath           |"
puts "|                                      |"
puts "|                            SunFounder|"
puts "========================================\n"
puts "Program is running..."
puts "Please press Ctrl+C to end the program..."
puts "Press Enter to begin\n"
raw_input = STDIN.gets
# Make all output on the same line
STDOUT.sync = true

# Set the GPIO modes to BCM Numbering
RPi::GPIO.set_numbering :bcm
# Set LED_PIN's mode to output, and initial level to low (0v)
RPi::GPIO.setup LED_PIN, as: :output, initialize: :low
# Set @pulsed_led as pwm output and frequece to 1KHz
@pulsed_led = RPi::GPIO::PWM.new(LED_PIN, 1000)
# Set @pulsed_led begin with value 0
@pulsed_led.start 0.0
# Set increase/decrease step
step = 2
# Set delay time.
delay = 0.05


at_exit do
  # Stop @pulsed_led
  @pulsed_led.stop
  # Turn off LED
  RPi::GPIO.set_high LED_PIN
  # Release resource
  RPi::GPIO.clean_up
  STDOUT.write "\r"
end

begin
  loop do
    # Increase duty cycle from 0 to 100
    (0..100).step(step).each do |dc|
      # Change duty cycle to dc
      @pulsed_led.duty_cycle = dc
      STDOUT.write "\r++ Duty cycle: #{dc}"
      sleep delay
    end

    STDOUT.write "\r  PAUSE                "
    sleep 1

    # decrease duty cycle from 100 to 0
    (-100..0).step(step).each do |dc|
      # Change duty cycle to dc
      @pulsed_led.duty_cycle = dc.abs
      STDOUT.write "\r-- Duty cycle: #{dc.abs} "
      sleep delay
    end
  end
rescue Interrupt, SignalException
  exit
end
