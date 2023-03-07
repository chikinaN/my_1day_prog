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

# 敵のサンプル
class Enemy < Sprite
  SIZE = 40

  def deta_values
    [0, 0, SIZE - 1, 10, 10, SIZE - 1]
  end

  def initialize
    x = rand(Walls::SIZE..Window.width - Walls::SIZE)
    y = Walls::SPACE
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
    if (@hp == 0)
      self.vanish
      self.image = nil
      GAME_STATE[:score] += 1
    else
      @hp -= 1
      self.image = @img_hit
    end
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
  end
end

# 弾のサンプル
class Bullet < Sprite
  SIZE = 20
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
    @dx = rand(-1..1)
    @dy = rand(-6..-5)
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
    item = Walls::SIZE
    self.x += @dx
    self.y += @dy
    if self.x < 0 + item || self.x > Window.width - item - Bullet::SIZE || self.y < 0 + Walls::SPACE + item
      self.vanish
    end
  end
end

# プレイヤー
class Player < Sprite
  SIZE = 50

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
    @bullets = []
    super(x, y, @img_normal)
  end
  attr_reader :bullets

  def make_bullets
    (N_BULLETS - @bullets.length).times{ @bullets << Bullet.new(@x + SIZE / 2, @y) }
  end

  def shot(other)
    GAME_STATE[:scene] = :game_over
  end

  def update
    move_by_input
    keep_within_window
  end

  def move_by_input
    self.x += Input.x * 8
    self.y += Input.y * 8
  end

  def keep_within_window
    item = Walls::SIZE
    self.x = [self.x, item].max
    self.x = [self.x, Window.width - SIZE - item].min
    self.y = [self.y, item + Walls::SPACE].max
    self.y = [self.y, Window.height - SIZE - item].min
  end
end

# 壁
class Walls < Array
  SIZE = 20
  SPACE = 120
  def initialize
    super
    self << Wall.new(0, 0, SIZE, Window.height)
    self << Wall.new(0, Window.height - SIZE, Window.width, SIZE)
    self << Wall.new(0, 0, Window.width, SIZE)
    self << Wall.new(Window.width - SIZE, 0, SIZE, Window.height)
    self << Wall.new(0, SPACE, Window.width, SIZE)
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
    set_item
  end

  def reset
    GAME_STATE[:score] = 0
    set_item
  end

  def set_item
    @player = Player.new
    @enemies = N_ENEMIES.times.map { Enemy.new }
    @wall = Walls.new
    @count = 60
  end

  def draw
    Window.loop do
      Sprite.draw(@wall)
      game_data
    end
  end

  def game_data
    case GAME_STATE[:scene]
    when :title
      draw_title_scene
    when :playing
      update_playing_scene
    when :game_over
      draw_game_over_scene
    when :game_clear
      draw_game_clear_scene
    end
  end

  def draw_title_scene
    Window.draw_font(21, 21, 'PRESS SPACE', Font.default)
    game_re_create
  end

  def update_playing_scene
    @sprites = [@player] + @player.bullets + @enemies
    item_draw
    Window.draw_font(Walls::SIZE, Walls::SIZE, "SCORE: #{GAME_STATE[:score]}", Font.default)
    Window.draw_font(Walls::SIZE, Walls::SIZE + 30, "time: #{@count.floor}", Font.default)
    item_update
    item_clean
    @player.make_bullets
    clear_count
    countdown
  end

  def draw_game_over_scene
    Window.draw_font(Walls::SIZE, Walls::SIZE, 'GAME OVER', Font.default)
    Window.draw_font(Walls::SIZE, Walls::SIZE + Font.default, 'PRESS SPACE', Font.default)
    game_re_create
  end

  def clear_count
    if (GAME_STATE[:score] == 1200)
      GAME_STATE[:scene] = :game_clear
    end
  end

  def countdown
    @count -= 1 / 60
    if (@count == 0)
      GAME_STATE[:scene] = :game_over
    end
  end

  def draw_game_clear_scene
    Window.draw_font(Walls::SIZE, Walls::SIZE, 'GAME CLEAR', Font.default)
    Window.draw_font(Walls::SIZE, Walls::SIZE + 30, 'PRESS SPACE', Font.default)
    game_re_create
  end

  def game_re_create
    if Input.key_push?(K_SPACE)
      reset
      GAME_STATE[:scene] = :playing
    end
  end

  def item_draw
    Sprite.draw(@sprites)
    @player.make_bullets
  end

  def item_update
    Sprite.check(@player.bullets, @enemies)
    Sprite.check(@enemies, @player)
    Sprite.update(@sprites)
    rand(N_ENEMIES - @enemies.length).times { @enemies << Enemy.new }
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
