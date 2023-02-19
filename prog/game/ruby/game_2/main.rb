require 'dxopal'
include DXOpal

Window.bgcolor = C_BLACK

GAME_STATE = {
  scene: :title,
  score: 0
}

# 棒
class Bar < Sprite
  def initialize(x = 0, y = 460)
    super(x, y)
    self.image = Image.new(100, 20, C_WHITE)
  end
  def update
    self.x = Input.mouse_pos_x
  end
end

class Walls < Array
  def initialize
    super
    self << Wall.new(0, 0, 20, 480)
    self << Wall.new(0, 0, 640, 20)
    self << Wall.new(620, 0, 20, 480)
  end
  
  def draw
    Sprite.draw(self)
  end
end

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
    5.times do |y|
      10.times do |x|
        self << Block.new(21 + 60 * x , 21 + 20 * y, colors[y])
      end
    end
  end
  def draw
    self.each do |b|
      b.draw
    end
  end
end

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
    # 横方向への移動
    self.x += @dx
    # 壁または棒に衝突
    if self === walls or self === bar
      self.x -= @dx
      @dx *= -1
    end
    # ブロックに衝突
    hit = self.check(blocks).first
    if hit != nil
      hit.vanish
      blocks.delete(hit)
      self.x -= @dx
      @dx *= -1
    end
    # 縦方向への移動
    self.y += @dy
    # 壁または棒に衝突
    if self === walls or self === bar
      self.y -= @dy
      @dy *= -1
    end
    # ブロックに衝突
    hit = self.check(blocks).first
    if hit != nil
      hit.vanish
      blocks.delete(hit)
      self.y -= @dy
      @dy *= -1
    end
    if self.y >= 480
      GAME_STATE[:scene] = :game_over
    end
  end
end

class Game
  def initialize
    reset
  end
  def reset
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
          Window.draw_font(0, 30, "PRESS SPACE", Font.default)
          if Input.key_push?(K_SPACE)
            GAME_STATE[:scene] = :playing
          end
        when :playing
          @bar.update
          @bar.draw
          @ball.update(@walls, @bar, @blocks)
          @ball.draw
          @blocks.draw
        when :game_over
          Window.draw_font(0, 30, "GAME OVER", Font.default)
          Window.draw_font(0, 60, "PRESS SPACE", Font.default)
          if Input.key_push?(K_SPACE)
            reset
            GAME_STATE[:scene] = :playing
          end
      end
    end
  end
end

Window.load_resources do
  game = Game.new
  game.run
end
