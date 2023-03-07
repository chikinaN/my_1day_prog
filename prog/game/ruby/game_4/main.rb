# frozen_string_literal: true

require 'dxopal'
include DXOpal

GAME_STATE = {
  score: 0
}

# 敵のサンプル
class Enemy < Sprite
  SIZE = 40

  def deta_values
    [0, 0, SIZE - 1, 10, 10, SIZE - 1]
  end

  def initialize
    x = rand(Walls::SIZE..Window.width - Walls::SIZE)
    y = 0
    @hp = 2
    @img_normal = create_triangle_image(SIZE, C_WHITE)
    super(x, y, @img_normal)
    @img_hit = create_triangle_image(SIZE, C_RED)
    self.collision = deta_values
    @dy = rand(1..6)
    @drot = rand(1..8)
  end

  def create_triangle_image(size, color)
    img = Image.new(size, size)
    img.triangle_fill(size / 2, 0, size - 1, size - 1, 0, size - 1, color)
    img
  end

  def hit(other)
    @hp -= 1
    self.image = @img_hit
  end

  def update
    self.y += @dy
    self.angle = (angle + @drot) % 360
    enemy_delete
  end

  def enemy_delete
    if self.y >= Window.height
      self.vanish
      self.image = nil
    end
    if (@hp == 0)
      self.vanish
      self.image = nil
      GAME_STATE[:score] += 1
    end
  end

end

# 弾のサンプル
class Bullet < Sprite
  SIZE = 10
  def deta_values
    [SIZE / 2, SIZE / 2, (SIZE / 2) - 1]
  end

  def initialize(px, py)
    x = px - SIZE / 2
    y = py
    @hp = 2
    @img_normal = Image.new(SIZE, SIZE)
    @img_normal.circle_fill(*deta_values, C_YELLOW)
    super(x, y, @img_normal)
    self.collision = deta_values
    @dx = rand(-4..3)
    @dy = rand(-6..-4)
  end

  def shot(other)
    if (@hp == 0)
      self.vanish
      self.image = nil
    else
      @hp -= 1
    end
  end

  def update
    self.x += @dx
    self.y += @dy
    if self.x.negative? || self.x > Window.width || self.y.negative?
      self.vanish
    end
  end
end

# プレイヤー
class Player < Sprite
  SIZE = 30

  def data_values
    [SIZE / 2, 0, SIZE - 1, SIZE - 1, 0, SIZE - 1]
  end

  def initialize
    x = Window.width / 2
    y = Window.height - SIZE * 2
    @img_normal = Image.new(SIZE, SIZE)
    @img_normal.triangle_fill(*data_values, C_GREEN)
    @img_hit = Image.new(SIZE, SIZE)
    @img_hit.triangle_fill(*data_values, C_RED)
    self.collision = data_values
    @hit = false
    @bullets = []
    super(x, y, @img_normal)
  end
  attr_reader :bullets

  def make_bullets
    (N_BULLETS - @bullets.length).times{ @bullets << Bullet.new(@x + SIZE / 2, @y) }
  end

  def shot(other)
    @hit = true
  end

  def update
    self.x += Input.x * 8
    self.x = Window.width - SIZE - Walls::SIZE if self.x > Window.width - SIZE - Walls::SIZE
    self.x = 0 + Walls::SIZE if self.x < 0 + Walls::SIZE
    self.y += Input.y * 8
    self.y = Window.height - SIZE - Walls::SIZE if self.y > Window.height - SIZE - Walls::SIZE
    self.y = 0 + Walls::SIZE if self.y < 0 + Walls::SIZE
    self.image = @hit ? @img_hit : @img_normal
    @hit = false
  end
end

# 壁
class Walls < Array
  SIZE = 20
  def initialize
    super
    self << Wall.new(0, 0, SIZE, Window.height)
    self << Wall.new(0, Window.height - SIZE, Window.width, SIZE)
    self << Wall.new(0, 0, Window.width, SIZE)
    self << Wall.new(Window.width - SIZE, 0, SIZE, Window.height)
  end
end

# 壁のイメージ
class Wall < Sprite
  def initialize(x, y, width, height)
    super(x, y)
    self.image = Image.new(width, height, C_BLUE)
  end
end

class Game
  def initialize
    @player = Player.new
    @enemies = N_ENEMIES.times.map { Enemy.new }
    @wall = Walls.new
  end

  def draw
    Window.loop do
      @sprites = [@player] + @player.bullets + @enemies
      item_draw
      Window.draw_font(0, 0, "SCORE: #{GAME_STATE[:score]}", Font.default)
      item_update
      item_clean
      rand(N_ENEMIES - @enemies.length).times { @enemies << Enemy.new }
      @player.make_bullets
    end
  end

  def item_draw
    Sprite.draw(@wall)
    Sprite.draw(@sprites)
    @player.make_bullets
  end

  def item_update
    Sprite.check(@player.bullets, @enemies)
    Sprite.check(@enemies, @player)
    Sprite.update(@sprites)
  end

  def item_clean
    Sprite.clean(@enemies)
    Sprite.clean(@player.bullets)
  end

end

N_ENEMIES = 20
N_BULLETS = 30
Window.load_resources do
  game = Game.new
  game.draw
end
