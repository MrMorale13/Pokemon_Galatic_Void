 #=============================================================================
  # HGSS Rare Hunter trainer(s)
  #=============================================================================
class Rarehunter < Transitions::Transition_Base
    DURATION     = 1.6
    RAREHUNTER_X     = [ 1.5, -0.5, -0.5, 0.75,  1.5, -0.5]   # * Graphics.width
    RAREHUNTER_Y     = [-0.5,  1.0, -0.5,  1.5,  0.5, 0.75]   # * Graphics.height
    RAREHUNTER_ANGLE = [   1,  0.5, -1.5,   -1, -1.5,  0.5]   # * 360 * sprite.zoom_x

    def initialize_bitmaps
    @rarehunter_1_bitmap = RPG::Cache.transition("rarehunter_wedge_1")
    @rarehunter_2_bitmap = RPG::Cache.transition("rarehunter_wedge_2")
    @rarehunter_3_bitmap = RPG::Cache.transition("rarehunter_wedge_3")
    @rarehunter_4_bitmap = RPG::Cache.transition("rarehunter_wedge_4")
    @rarehunter_bitmap  = RPG::Cache.transition("rarehunter_logo")
      dispose if !@rarehunter_1_bitmap || !@rarehunter_2_bitmap || !@rarehunter_3_bitmap ||
                 !@rarehunter_4_bitmap || !@rarehunter_bitmap
    end

    def initialize_sprites
      # Rarehunter sprites
      @rarehunter_sprites = []
      RAREHUNTER_X.length.times do |i|
        @rarehunter_sprites[i] = new_sprite(
          RAREHUNTER_X[i] * Graphics.width, RAREHUNTER_Y[i] * Graphics.height,
          @rarehunter_bitmap, @rarehunter_bitmap.width / 2, @rarehunter_bitmap.height / 2
        )
      end
      # Rarehunter wedges
      4.times do |i|
        b = [@rarehunter_1_bitmap, @rarehunter_2_bitmap, @rarehunter_3_bitmap, @rarehunter_4_bitmap][i]
        @sprites[i] = new_sprite((i == 1) ? 0 : Graphics.width / 2, (i == 2) ? 0 : Graphics.height / 2, b,
                                 (i.even?) ? b.width / 2 : 0, (i.even?) ? 0 : b.height / 2)
        @sprites[i].zoom_x  = 0.0 if i.even?
        @sprites[i].zoom_y  = 0.0 if i.odd?
        @sprites[i].visible = false
      end
    end

    def set_up_timings
      @rarehunter_appear_end   = @duration * 0.75
      @rarehunter_appear_delay = 1.0 / (RAREHUNTER_X.length + 1)
      @rarehunter_appear_time  = @rarehunter_appear_delay * 2   # 2 logos on screen at once
    end

    def dispose_all
      # Dispose sprites
      @rarehunter_sprites.each { |s| s&.dispose }
      @rarehunter_sprites.clear
      # Dispose bitmaps
      @rarehunter_1_bitmap&.dispose
      @rarehunter_2_bitmap&.dispose
      @rarehunter_3_bitmap&.dispose
      @rarehunter_4_bitmap&.dispose
      @rarehunter_bitmap&.dispose
    end

    def update_anim
      if timer <= @rarehunter_appear_end
        # Rarehunter logos fly in from edges of screen
        proportion = timer / @rarehunter_appear_end
        @rarehunter_sprites.each_with_index do |sprite, i|
          next if !sprite.visible
          start_time = i * @rarehunter_appear_delay
          next if proportion < start_time
          single_proportion = (proportion - start_time) / @rarehunter_appear_time
          sqrt_single_proportion = Math.sqrt(single_proportion)
          sprite.x = (RAREHUNTER_X[i] + ((0.5 - RAREHUNTER_X[i]) * sqrt_single_proportion)) * Graphics.width
          sprite.y = (RAREHUNTER_Y[i] + ((0.5 - RAREHUNTER_Y[i]) * sqrt_single_proportion)) * Graphics.height
          sprite.zoom_x = 2.5 * (1 - single_proportion)
          sprite.zoom_y = sprite.zoom_x
          sprite.angle = sprite.zoom_x * RAREHUNTER_ANGLE[i] * 360
          sprite.visible = false if sprite.zoom_x <= 0
        end
      else
        @rarehunter_sprites.last.visible = false
        # Rarehunter wedges expand to fill screen
        proportion = (timer - @rarehunter_appear_end) / (@duration - @rarehunter_appear_end)
        @sprites.each_with_index do |sprite, i|
          sprite.visible = true
          sprite.zoom_x = proportion if i.even?
          sprite.zoom_y = proportion if i.odd?
        end
      end
    end
  end
