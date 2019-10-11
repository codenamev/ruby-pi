#!/usr/bin/env ruby

require "rpi_gpio"

# Set up a color table in Hexadecimal
COLOR = [
  0xFF0000, # red
  0x00FF00, # green
  0x0000FF, # blue
  0xFFFF00, # yellow
  0xFF00FF, # purple
  0xFF8000  # orange
]
# Set PINS' channels with dictionary
PINS = {"Red" => 17, "Green" => 18, "Blue" => 27}
BUTTON_PIN_NUMBER = 22
GUESS_DURATION = 3

puts "========================================"
puts "|           Guess the Color!           |"
puts "|    ------------------------------    |"
puts "|       Red Pin connect to GPIO0       |"
puts "|      Green Pin connect to GPIO1      |"
puts "|       Blue Pin connect to GPIO2      |"
puts "|       Button Pin connect to GPIO3    |"
puts "|                                      |"
puts "|  Make a RGB LED emits various color  |"
puts "|                                      |"
puts "|                            codenamev |"
puts "========================================\n"
puts "Program is running..."
puts "Please press Ctrl+C to end the program..."
puts "Press Enter to begin\n"
STDIN.gets

# Set the GPIO modes to BCM Numbering
RPi::GPIO.set_numbering :bcm
# Set all LedPin's mode to output, and initial level to High(3.3v)
PINS.values.each do |pin|
  RPi::GPIO.setup pin, as: :output, initialize: :high
end
# Set button to input and pull up to high (3.3V)
RPi::GPIO.setup BUTTON_PIN_NUMBER, as: :input, pull: :up

class MultiColorLED
  DEFAULT_FREQUENCY = 2_000 # in Hz
  PWMPin = Struct.new(:number, :pwm)

  class LEDColor < Struct.new(:hex_color)
    MAX_RGB_VALUE = 255
    RED = 0xFF0000
    GREEN = 0x00FF00
    BLUE = 0x0000FF

    # Extracts the first two values of the hexadecimal
    def red
      ((hex_color & RED) >> 16) / MAX_RGB_VALUE * 100
    end

    # Extracts the second two values of the hexadecimal
    def green
      ((hex_color & GREEN) >> 8) / MAX_RGB_VALUE * 100
    end

    # Extracts the last two values of the hexadecimal
    def blue
      (hex_color & BLUE) / MAX_RGB_VALUE * 100
    end
  end

  attr_reader :red_pin, :green_pin, :blue_pin

  def initialize(red_pin:, green_pin:, blue_pin:)
    @red_pin   = PWMPin.new(red_pin, RPi::GPIO::PWM.new(red_pin, DEFAULT_FREQUENCY))
    @green_pin = PWMPin.new(green_pin, RPi::GPIO::PWM.new(green_pin, DEFAULT_FREQUENCY))
    @blue_pin  = PWMPin.new(blue_pin, RPi::GPIO::PWM.new(blue_pin, DEFAULT_FREQUENCY))
    reset
    start
  end

  def reset
    red_pin.pwm.duty_cycle = 0
    green_pin.pwm.duty_cycle = 0
    blue_pin.pwm.duty_cycle = 0
  end

  def start
    red_pin.pwm.start(0)
    green_pin.pwm.start(0)
    blue_pin.pwm.start(0)
  end

  def stop
    # Stop all pwm channel
    red_pin.pwm.stop
    green_pin.pwm.stop
    blue_pin.pwm.stop
    # Turn off all LEDs
    RPi::GPIO.set_high red_pin.number
    RPi::GPIO.set_high green_pin.number
    RPi::GPIO.set_high blue_pin.number
  end

  # Sets each color's luminance
  # Duty Cylce (D) is the percentage of one period in which the signal is active.
  # Period (P) is the time it takes the signal to complete an on-off cycle.
  # Active Time (T) is the time the signal is active.
  #
  # D = T / P * 100%
  #
  # A 60% Duty Cycle means the signal is on 60% of the time and off 40% of the
  # time.  The "on time" for this cycle could be a fraction of a second, a day, or a
  # week.  It all depends on the length of the Period.
  def setColor(color_as_hex)
    led_color = LEDColor.new(color_as_hex)
    # Change the colors
    red_pin.pwm.duty_cycle   = led_color.red
    green_pin.pwm.duty_cycle = led_color.green
    blue_pin.pwm.duty_cycle  = led_color.blue

    puts "[Color Change] rgb(#{red_pin.pwm.duty_cycle}, #{green_pin.pwm.duty_cycle}, #{blue_pin.pwm.duty_cycle})"
  end
end

# Set all led as pwm channel, and frequency to 2KHz
@rgb_led = MultiColorLED.new(
  red_pin: PINS["Red"],
  blue_pin: PINS["Green"],
  green_pin: PINS["Blue"]
)

at_exit do
  @rgb_led.stop
  @rgb_led.reset
  # Release resource
  RPi::GPIO.clean_up
end

begin
  loop do
    if RPi::GPIO.high? BUTTON_PIN_NUMBER
      @rgb_led.reset
    else
      @rgb_led.setColor(COLOR.sample)
      sleep GUESS_DURATION
    end
  end
rescue Interrupt, SignalException
  exit
end

