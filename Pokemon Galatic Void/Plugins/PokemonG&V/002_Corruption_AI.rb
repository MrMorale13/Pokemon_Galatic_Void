#===============================================================================
# Pokemon Galactic Void - Corruption AI
# Pokemon Essentials v21.1
#===============================================================================

class Battle::AI
  #-----------------------------------------------------------------------------
  # Decide whether an AI-controlled battler should use Corruption.
  #
  # This mirrors Essentials' Mega Evolution AI:
  # if it can use the mechanic, it will.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldCorrupt?
    return false if !@user

    if @battle.pbCanCorrupt?(
         @user.index
       )

      pkmn =
        @user.battler.pokemon

      data =
        pkmn.getCorruptionData

      if data
        mode_name =
          (data[1] ==
           GalacticVoidCorruption::VOID) ?
          "Void" :
          "Galaxy"

        PBDebug.log_ai(
          "#{@user.name} will use " +
          "#{mode_name} Corruption"
        )
      else
        PBDebug.log_ai(
          "#{@user.name} will use Corruption"
        )
      end

      return true
    end

    return false
  end


  #-----------------------------------------------------------------------------
  # Register Corruption once the AI has committed to using a move.
  #
  # This avoids wasting Corruption if it switches or uses an item instead.
  #-----------------------------------------------------------------------------

  alias \
    gv_corruption_ai_pbChooseMove \
    pbChooseMove

  def pbChooseMove(choices)

    if pbEnemyShouldCorrupt?

      @battle.pbRegisterCorruption(
        @user.index
      )
    end

    gv_corruption_ai_pbChooseMove(
      choices
    )
  end
end