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
COLORS = [C_BLUE, C_YELLOW, C_WHITE, C_RED, C_GREEN]

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

# ブロック生成
class Blocks < Array
  def initialize
    super
    6.times do |y|
      10.times do |x|
        GAME_STATE[:score] += 1
        self << rand_create(x, y)
      end
    end
  end

  def rand_create(x, y)
    bc = y % 5
    if rand(10) <= 8
      Block.new(21 + 60 * x, 141 + 20 * y, COLORS[bc])
    else
      Block_2count.new(21 + 60 * x, 141 + 20 * y, COLORS[1])
    end
  end

  def draw
    each do |b|
      b.draw
    end
  end
end

# ブロックのベースクラス
class BlockBase < Sprite
  def initialize(x, y, c, hit_count)
    super(x, y)
    self.image = Image.new(58, 18, c)
    @hit_count = hit_count
  end

  def hit_count
    @hit_count
  end

  def hit
    @hit_count -= 1
    if @hit_count < 0
      self.vanish
    else
      self.image = Image.new(58, 18, C_CYAN)
    end
  end
end

# 2回目で壊れるブロック
class Block_2count < BlockBase
  def initialize(x, y, c)
    super(x, y, c, 1)
  end
end

# 普通のブロック
class Block < BlockBase
  def initialize(x, y, c)
    super(x, y, c, 0)
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
    if y >= 600
      GAME_STATE[:scene] = :game_over
    end
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
    if hit.hit_count == 0
      blocks.delete(hit)
      hit.vanish
    else
      hit.hit
    end
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
    Window.draw_font(21, 21, 'PRESS SPACE', Font.default)
    if Input.key_push?(K_SPACE)
      GAME_STATE[:scene] = :playing
    end
  end

  def update_playing_scene
    content_detail
    @bar.update
    @bar.draw
    @ball.update(@walls, @bar, @blocks)
    @ball.draw
    @blocks.draw
    if @ball.y >= 600
      GAME_STATE[:scene] = :game_over
    end
  end

  def content_detail
    Window.draw_font(21, 21, "SCORE: #{GAME_STATE[:score]}", Font.default)
  end

  def draw_game_over_scene
    Window.draw_font(21, 21, 'GAME OVER', Font.default)
    Window.draw_font(21, 51, 'PRESS SPACE', Font.default)
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
