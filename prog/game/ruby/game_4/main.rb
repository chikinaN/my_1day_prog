# frozen_string_literal: true

require 'dxopal'
include DXOpal

Window.bgcolor = C_BLACK
Window.width = 700
Window.height = 600

GAME_INFO = {
  scene: :title,
  score: 0,
  health: 15
}

# ゲームオブジェクトの基礎
class GameObject < Sprite
  def update
    # 何もしない
  end

  def outside_window?
    self.x < 0 || self.x > Window.width || self.y < 0 || self.y > Window.height
  end
end

# 弾のイメージ
class Bullet < GameObject
  def initialize(x, y, speed)
    super(x, y)
    self.image = Image.new(20, 20).circle_fill(10, 10, 10, C_WHITE)
    @dx = 0
    @dy = speed
  end

  def update
    self.y += @dy
    self.vanish if outside_window?
  end
end

# 普通の弾の強さ
class Shot < GameObject
  def initialize(px, py, speed)
    super(px, py)
    @dx = 0
    @dy = -speed
    self.image = Image.new(10, 30).rect(2, 0, 6, 30, C_WHITE)
  end

  def update
    self.y += @dy
    self.vanish if outside_window?
  end

  def create_bullet
    Bullet.new(self.x, self.y, 5)
  end
end

# プレイヤークラス
class Player < GameObject
  def initialize
    super
    self.image = Image.new(30, 30).circle_fill(15, 15, 15, C_RED)
    self.x = Window.width / 2 - self.image.width / 2
    self.y = Window.height - self.image.height - 50
  end

  def update
    ps = 5
    self.x += Input.x * ps
    self.y += Input.y * ps
    self.x = [[self.x, 0].max, Window.width - self.image.width].min
    self.y = [[self.y, 0].max, Window.height - self.image.height].min
  end

  def fire_shot
    shot = Shot.new(self.x + 15, self.y - 10, 10)
    shot.add
    shot.add(shot.create_bullet)
  end

  def input
    self.x += Input.key_down?(K_D) ? 5 : 0
    self.x -= Input.key_down?(K_A) ? 5 : 0
    self.y += Input.key_down?(K_S) ? 5 : 0
    self.y -= Input.key_down?(K_W) ? 5 : 0
  end
end

class PlayerImage < Image
  def initialize
    super(30, 30)
    circle_fill(15, 15, 15, C_WHITE)
  end
end

# スコアボードのクラス
class ScoreBoard
  def initialize
    score_content
  end

  def draw
    score_content
  end

  def score_content
    Window.draw_font(21, 21, "Score: #{GAME_INFO[:score]}", Font.default)
  end
end

# ヘルスボードのクラス
class HealthBoard
  def initialize(x, y, initial_health)
    super(x, y)
    @x = x
    @y = y
    @health = initial_health
    @heart_image = Image.new(20, 20).circle_fill(10, 10, 10, C_RED)
  end

  def draw
    @health.times do |i|
      Window.draw(@x + i * 20, @y, @heart_image)
    end
  end

  def damage(damage)
    @health -= damage
  end

  def game_over?
    @health <= 0
  end
end

# 壁やスコア、ヘルスなど様々な背景を定義
class Frame < Array
  def initialize
    super
    self << Wall.new(0, 0, 20, 600)
    self << Wall.new(0, 90, 700, 20)
    self << Wall.new(0, 0, 700, 20)
    self << Wall.new(680, 0, 20, 600)
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

# ゲームのまとめ処理
class Game
  def initialize
    @frame = Frame.new
    @player = Player.new
    @score_board = ScoreBoard.new
    @health_board = HealthBoard.new(600, 10, GAME_INFO[:health])
  end

  def update
    case GAME_INFO[:scene]
    when :title
      update_title
    when :playing
      update_playing
    when :game_over
      update_game_over
    when :game_clear
      update_game_clear
    end
  end

  def draw
    case GAME_INFO[:scene]
    when :title
      draw_title
    when :playing
      draw_playing
    when :game_over
      draw_game_over
    when :game_clear
      draw_game_clear
    end
  end

  def update_title
    if Input.key_push?(K_SPACE)
      GAME_INFO[:scene] = :playing
    end
  end

  def update_playing
    Sprite.update([@player, @frame, @score_board, @health_board])
    @player.input
    if Input.key_push?(K_SPACE)
      @player.fire_shot
    end
    if GAME_INFO[:health] <= 0
      GAME_INFO[:scene] = :game_over
    end
  end

  def update_game_over
    if Input.key_push?(K_SPACE)
      GAME_INFO[:health] = 15
      GAME_INFO[:score] = 0
      @player = Player.new
      GAME_INFO[:scene] = :playing
    end
  end

  def update_game_clear
    if Input.key_push?(K_SPACE)
      GAME_INFO[:health] = 15
      GAME_INFO[:score] = 0
      @player = Player.new
      GAME_INFO[:scene] = :playing
    end
  end

  def draw_title
    Window.draw_font(200, 280, "Press SPACE to start", Font.default)
  end

  def draw_playing
    Sprite.draw([@player, @frame, @score_board, @health_board])
  end

  def draw_game_over
    Window.draw_font(250, 280, "GAME OVER", Font.default)
    Window.draw_font(200, 320, "Press SPACE to restart", Font.default)
  end

  def draw_game_clear
    Window.draw_font(250, 280, "GAME CLEAR!", Font.default)
    Window.draw_font(200, 320, "Press SPACE to restart", Font.default)
  end
end

# ウィンドウの表示
Window.load_resources do
  game = Game.new
  Window.loop do
    game.update
    game.draw
  end
end
