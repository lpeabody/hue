module Hue
  class Cli < CliBase
    desc 'lights', 'Find all of the lights on your network'
    shared_options
    def lights
      client(options[:user]).lights.each do |light|
        puts light.id.to_s.ljust(6) + light.name
      end
    end

    desc 'add LIGHTS', 'Search for new lights'
    shared_options
    def add(thing)
      case thing
      when 'lights'
        client(options[:user]).add_lights
      end
    end

    desc 'all STATE', 'Send commands to all lights'
    shared_options
    def all(state)
      on = state == 'on'
      client(options[:user]).lights.each do |light|
        light.on = on
      end
    end

    desc 'light ID STATE [COLOR]', 'Access a light'
    long_desc <<-LONGDESC
    Examples: \n
      hue light 1 on --hue 12345  \n
      hue light 1 --bri 25 \n
      hue light 1 --alert lselect \n
      hue light 1 off
    LONGDESC
    shared_options
    method_option :hue, :type => :numeric
    method_option :sat, :type => :numeric
    method_option :bri, :type => :numeric
    method_option :alert, :type => :string
    method_option :effect, :type => :string
    method_option :transitiontime, :type => :numeric
    def light(id, state = nil)
      light = client(options[:user]).light(id)
      puts light.name

      body = options.dup
      # We no longer need :user so remove it.
      body.delete(:user)
      body[:on] = (state == 'on' || !(state == 'off'))
      puts light.set_state(body) if body.length > 0
    end

  private

    def client(username = Hue::USERNAME)
      @client ||= Hue::Client.new username
    end
  end
end
