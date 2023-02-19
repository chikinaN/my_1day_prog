# frozen_string_literal: true

require 'dxopal'
include DXOpal

Window.bgcolor = C_BLACK
Window.width = 640
Window.height = 600

GAME_STATE = {
  scene: :title,
  score: 0
}

# 棒
class Bar < Sprite
  def initialize(x = 0, y = 580)
    super(x, y)
    self.image = Image.new(100, 20, C_WHITE)
  end

  def update
    self.x = Input.mouse_pos_x - 50
  end
end

# 壁
class Walls < Array
  def initialize
    super
    self << Wall.new(0, 0, 20, 600)
    self << Wall.new(0, 120, 640, 20)
    self << Wall.new(0, 0, 640, 20)
    self << Wall.new(620, 0, 20, 600)
  end

  def draw
    Sprite.draw(self)
  end
end

# 壁のイメージ
class Wall < Sprite
  def initialize(x, y, width, height)
    super(x, y)
    self.image = Image.new(width, height, C_BLUE)
  end
end

# ブロック
class Blocks < Array
  def initialize
    super
    colors = [C_BLUE, C_YELLOW, C_WHITE, C_RED, C_GREEN]
    6.times do |y|
      bc = y % 5
      10.times do |x|
        GAME_STATE[:score] += 1
        self << Block.new(21 + 60 * x, 141 + 20 * y, colors[bc])
      end
    end
  end

  def draw
    each do |b|
      b.draw
    end
  end
end

# ブロックのイメージ
class Block < Sprite
  def initialize(x, y, c)
    super(x, y)
    self.image = Image.new(58, 18, c)
  end
end

# ボール
class Ball < Sprite
  def initialize(x = 300, y = 400)
    super(x, y)
    self.image = Image.new(20, 20).circle_fill(10, 10, 10, C_WHITE)
    @dx =  4
    @dy = -4
  end

  def update(walls, bar, blocks)
    x_update(walls, bar, blocks)
    y_update(walls, bar, blocks)
    GAME_STATE[:scene] = :game_over if y >= 600
  end

  def x_update(walls, bar, blocks)
    self.x += @dx
    reverse_x if self === walls || self === bar
    hit = check(blocks).first
    if !hit.nil?
      clear(hit, blocks)
      reverse_x
    end
  end

  def reverse_x
    self.x -= @dx
    @dx *= -1
  end

  def y_update(walls, bar, blocks)
    self.y += @dy
    reverse_y if self === walls || self === bar
    hit = check(blocks).first
    if !hit.nil?
      clear(hit, blocks)
      reverse_y
    end
  end

  def reverse_y
    self.y -= @dy
    @dy *= -1
  end

  def clear(hit, blocks)
    GAME_STATE[:score] -= 1
    blocks.delete(hit)
    hit.vanish
  end
end

# ゲーム
class Game
  def initialize
    set_item
  end

  def reset
    GAME_STATE[:score] = 0
    set_item
  end

  def set_item
    @walls = Walls.new
    @bar = Bar.new
    @ball   = Ball.new
    @blocks = Blocks.new
  end

  def run
    Window.loop do
      @walls.draw
      case GAME_STATE[:scene]
      when :title
        draw_title_scene
      when :playing
        update_playing_scene
      when :game_over
        draw_game_over_scene
      end
    end
  end

  def draw_title_scene
    Window.draw_font(0, 30, 'PRESS SPACE', Font.default)
    GAME_STATE[:scene] = :playing if Input.key_push?(K_SPACE)
  end

  def update_playing_scene
    Window.draw_font(0, 0, "SCORE: #{GAME_STATE[:score]}", Font.default)
    @bar.update
    @bar.draw
    @ball.update(@walls, @bar, @blocks)
    @ball.draw
    @blocks.draw
    GAME_STATE[:scene] = :game_over if @ball.y >= 600
  end

  def draw_game_over_scene
    Window.draw_font(0, 30, 'GAME OVER', Font.default)
    Window.draw_font(0, 60, 'PRESS SPACE', Font.default)
    if Input.key_push?(K_SPACE)
      reset
      GAME_STATE[:scene] = :playing
    end
  end
end

Window.load_resources do
  game = Game.new
  game.run
end
