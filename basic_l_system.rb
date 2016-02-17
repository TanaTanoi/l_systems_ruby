require 'gosu'

class Game < Gosu::Window
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  BLACK = Gosu::Color.argb(0xff_111111)
  WHITE = Gosu::Color.argb(0xff_ffffff)

  START_X = SCREEN_WIDTH/2
  START_Y = SCREEN_HEIGHT/2
  DEFAULT_LENGTH = 10

  SYSTEMS = {
    tree: {
      axiom: '0',
      angle: 45,
      rules: {
        '1' => '11',
        '0' => '1[0]0'
      }
    },
    triangle: {
      axiom: 'a',
      angle: 60,
      rules: {
        'a' => '=b-a-b=',
        'b' => '-a=b=a-'
      }
    },
    dragon: {
      axiom: 'fx',
      angle: 90,
      rules: {
        'x' => 'x=yf=',
        'y' => '-fx-y'
      }
    },
    plant: {
      axiom: 'x',
      angle: -25,
      rules: {
        'x' => 'f−[[x]=x]=f[=fx]−x',
        'f' => 'ff'
      }
    },
    koch: {
      axiom: 'f',
      angle: 90,
      rules: {
        'f' => 'f=f-f-f=f'
      }
    },
  }

  SYSTEM_NUMBER = SYSTEMS.map.with_index do |hash, i|
    [i+1, hash.first]
  end.to_h

  attr_reader :width, :height

  def initialize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT, fullscreen: false)
    super(width, height, fullscreen)
    self.caption = "things"
    start
  end

  def start(system: SYSTEMS.first.first)
    @current_system = system
    @current_string = current_system[:axiom]
    @position_stack = []
    @direction_stack = []
    @start_x = START_X
    @start_y = START_Y
    @length = DEFAULT_LENGTH
    @mode = :instant
    @current_steps = 0
  end

  def update
  end

  def draw
    draw_current_string
    if @mode == :instant
      draw_current_system
    elsif @mode == :step
      step_draw_current_system(@current_steps)
      @current_steps = [@current_steps + 5, @current_string.length].min
    end
    draw_cursor
  end

  def click(x, y)
    @start_x = x
    @start_y = y
  end

  def button_down(id)
    if id == 256
      click(self.mouse_x, self.mouse_y)
      return
    end
    char = button_id_to_char(id)
    if char == " "
      step_current_string
    elsif char == 'w'
      @length *= 2
    elsif char == 's'
      @length *= 0.5
    elsif char == 'q'
      @mode = (@mode == :instant ? :step : :instant)
    elsif char.to_i != 0
      num = char.to_i
      start(system: SYSTEM_NUMBER[num])
    else
      @current_string = "#{@current_string}#{char}"
    end
  end

  private

  def step_current_string
    @current_steps = 0
    @current_string = iterate_string(@current_string)
  end

  def system_name
    current_system.first
  end

  def draw_current_string
    Gosu::Font.new(30).draw("#{@current_system}: #{@current_string}", 0, SCREEN_WIDTH/2, 0, scale_x = 1, scale_y = 1, color = 0xff_ffffff)
  end

  def draw_cursor
    Gosu::draw_rect(self.mouse_x, self.mouse_y, 5,5,WHITE)
  end

  def step_draw_current_system(max_chars)
    @current_x = @start_x
    @current_y = @start_y
    @direction = 0
    angle = current_system[:angle]
    @current_string.split("").first(max_chars).each do |char|
      do_action(char, angle)
    end
  end

  def draw_current_system
    @current_x = @start_x
    @current_y = @start_y
    @direction = 0
    angle = current_system[:angle]
    @current_string.split("").each do |char|
      do_action(char, angle)
    end
  end

  def do_action(char, angle)
    case char
    when '1' then draw_line(@current_x, @current_y, @direction, @length)
    when '0' then draw_line(@current_x, @current_y, @direction, @length)
    when '[' then push_state_and_rotate(angle)
    when ']' then pop_state_and_rotate(-angle)
    when 'a' then draw_line(@current_x, @current_y, @direction, @length)
    when 'b' then draw_line(@current_x, @current_y, @direction, @length)
    when '=' then @direction += angle
    when '-' then @direction -= angle
    when 'f' then draw_line(@current_x, @current_y, @direction, @length)
    end
  end

  def push_state_and_rotate(angle)
    @position_stack << {x: @current_x, y: @current_y}
    @direction_stack << @direction
    @direction += angle
  end

  def current_system
    SYSTEMS[@current_system]
  end

  def pop_state_and_rotate(angle)
    position = @position_stack.pop
    @current_x = position[:x]
    @current_y = position[:y]
    @direction = @direction_stack.pop
    @direction += angle
  end

  def draw_line(start_x, start_y, direction, length)
    theta = direction * (Math::PI / 180)
    end_x = Math.sin(theta) * length + start_x
    end_y = Math.cos(theta) * -length + start_y
    @current_x = end_x
    @current_y = end_y
    Gosu::draw_line(start_x, start_y, WHITE, end_x, end_y, WHITE, 0)
  end

  def iterate_string(string, system: @current_system)
    rules = SYSTEMS[@current_system][:rules]
    string.split('').map do |char|
       rules[char].nil? ? char : rules[char]
    end.join
  end
end