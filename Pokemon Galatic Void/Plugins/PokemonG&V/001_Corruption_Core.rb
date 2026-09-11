#===============================================================================
# Pokemon Galactic Void - Corruption Core
# Pokemon Essentials v21.1
#===============================================================================

module GalacticVoidCorruption
  VOID   = :VOID
  GALAXY = :GALAXY

  VOID_FORM   = 10
  GALAXY_FORM = 11

  # ITEM => [SPECIES, MODE, NORMAL FORM, CORRUPTION FORM]
  STONES = {
    :OBLIVIXVOIDCORE   => [:OBLIVIX,   VOID,   0, VOID_FORM],
    :OBLIVIXSTARCORE   => [:OBLIVIX,   GALAXY, 0, GALAXY_FORM],

    :ERUPTILEVOIDCORE  => [:ERUPTILE,  VOID,   0, VOID_FORM],
    :ERUPTILESTARCORE  => [:ERUPTILE,  GALAXY, 0, GALAXY_FORM],

    :MORTARINEVOIDCORE => [:MORTARINE, VOID,   0, VOID_FORM],
    :MORTARINESTARCORE => [:MORTARINE, GALAXY, 0, GALAXY_FORM],

    :GALLADEVOIDCORE   => [:GALLADE,   VOID,   0, VOID_FORM],
    :GALLADESTARCORE   => [:GALLADE,   GALAXY, 0, GALAXY_FORM],

    :GARCHOMPSTARCORE  => [:GARCHOMP,  GALAXY, 0, GALAXY_FORM],
    :HYDREIGONSTARCORE => [:HYDREIGON, GALAXY, 0, GALAXY_FORM],

    :GENGARVOIDCORE    => [:GENGAR,    VOID,   0, VOID_FORM],
    :FLAREONVOIDCORE   => [:FLAREON,   VOID,   0, VOID_FORM],
    :SWAMPERTVOIDCORE  => [:SWAMPERT,  VOID,   0, VOID_FORM],
    :ELECTIVIREVOIDCORE=> [:ELECTIVIRE,VOID,   0, VOID_FORM],

    # Lucario:
    # 0 = Normal
    # 1 = Mega
    # 2 = Void
    # 3 = Galaxy
    :LUCARIOVOIDCORE   => [:LUCARIO,   VOID,   0, 2],
    :LUCARIOSTARCORE   => [:LUCARIO,   GALAXY, 0, 3],

    :KINGAMBITVOIDCORE => [:KINGAMBIT, VOID,   0, VOID_FORM],
    :CERULEDGEVOIDCORE => [:CERULEDGE, VOID,   0, VOID_FORM],
    :HARIYAMAVOIDCORE  => [:HARIYAMA,  VOID,   0, VOID_FORM],
    :MACHAMPVOIDCORE   => [:MACHAMP,   VOID,   0, VOID_FORM],
    :METAGROSSVOIDCORE => [:METAGROSS, VOID,   0, VOID_FORM],
    :GOLURKVOIDCORE    => [:GOLURK,    VOID,   0, VOID_FORM],
    :SABLEYEVOIDCORE   => [:SABLEYE,   VOID,   0, VOID_FORM],
    :AGGRONVOIDCORE    => [:AGGRON,    VOID,   0, VOID_FORM],
    :TYRANTRUMVOIDCORE => [:TYRANTRUM, VOID,   0, VOID_FORM],
    :RHYPERIORVOIDCORE => [:RHYPERIOR, VOID,   0, VOID_FORM],
    :URSHIFUVOIDCORE   => [:URSHIFU,   VOID,   0, VOID_FORM],
    :BANETTEVOIDCORE   => [:BANETTE,   VOID,   0, VOID_FORM],
    :VICTREEBELVOIDCORE=> [:VICTREEBEL,VOID,   0, VOID_FORM],
    :VIKAVOLTVOIDCORE  => [:VIKAVOLT,  VOID,   0, VOID_FORM],
    :VOLCARONAVOIDCORE => [:VOLCARONA, VOID,   0, VOID_FORM],
    :WAILORDVOIDCORE   => [:WAILORD,   VOID,   0, VOID_FORM],

    # Tyranitar:
    # 0 = Normal
    # 1 = Mega
    # 2 = Void
    :TYRANITARVOIDCORE => [:TYRANITAR, VOID,   0, 2],

    :MAWILEVOIDCORE    => [:MAWILE,    VOID,   0, VOID_FORM]
  }

  DRAIN_DENOMINATOR = 8


  #=============================================================================
  # Gets Corruption Core data
  #=============================================================================

  def self.stone_data(pkmn)
    return nil if !pkmn

    data = STONES[pkmn.item_id]

    return nil if !data
    return nil if pkmn.species != data[0]

    return data
  end


  #=============================================================================
  # Checks whether the required Corruption form exists
  #=============================================================================

  def self.form_exists?(species, form)
    form_id =
      sprintf(
        "%s_%d",
        species,
        form
      ).to_sym

    return GameData::Species.exists?(
      form_id
    )
  end


  #=============================================================================
  # Stat multipliers
  #=============================================================================

  def self.attack_multiplier(mode)
    return 2.5 if mode == VOID
    return 1.25 if mode == GALAXY
    return 1.0
  end


  def self.defense_multiplier(mode)
    return 1.5 if mode == VOID
    return 2.5 if mode == GALAXY
    return 1.0
  end


  def self.speed_multiplier(mode)
    return 1.5 if mode == VOID
    return 1.0
  end
end


#===============================================================================
# Pokemon-side Corruption
#===============================================================================

class Pokemon
  attr_reader :corruption_mode


  def corrupted?
    return !@corruption_mode.nil?
  end


  def getCorruptionData
    return GalacticVoidCorruption.stone_data(
      self
    )
  end


  def hasCorruptionForm?
    return false if corrupted?

    data =
      getCorruptionData

    return false if !data

    return false if
      form_simple != data[2]

    return GalacticVoidCorruption.form_exists?(
      data[0],
      data[3]
    )
  end


  def makeCorrupted
    data =
      getCorruptionData

    return false if !data

    return false if
      form_simple != data[2]

    return false if
      !GalacticVoidCorruption.form_exists?(
        data[0],
        data[3]
      )

    @corruption_base_form =
      form_simple

    @corruption_mode =
      data[1]

    self.form =
      data[3]

    return true
  end


  def makeUncorrupted
    return if !corrupted?

    old_form =
      @corruption_base_form || 0

    @corruption_mode = nil
    @corruption_base_form = nil

    self.form =
      old_form
  end
end


#===============================================================================
# Battler-side Corruption
#===============================================================================

class Battle::Battler

  def hasCorruption?
    return false if
      @effects[
        PBEffects::Transform
      ]

    return false if !@pokemon

    return @pokemon.hasCorruptionForm?
  end


  def corrupted?
    return false if !@pokemon

    return @pokemon.corrupted?
  end


  def corruption_mode
    return nil if !@pokemon

    return @pokemon.corruption_mode
  end


  #=============================================================================
  # Attack
  #=============================================================================

  alias \
    gv_corruption_attack \
    attack

  def attack
    value =
      gv_corruption_attack

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        attack_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Special Attack
  #=============================================================================

  alias \
    gv_corruption_spatk \
    spatk

  def spatk
    value =
      gv_corruption_spatk

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        attack_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Defense
  #=============================================================================

  alias \
    gv_corruption_defense \
    defense

  def defense
    value =
      gv_corruption_defense

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        defense_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Special Defense
  #=============================================================================

  alias \
    gv_corruption_spdef \
    spdef

  def spdef
    value =
      gv_corruption_spdef

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        defense_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Raw Speed
  #=============================================================================

  alias \
    gv_corruption_speed \
    speed

  def speed
    value =
      gv_corruption_speed

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        speed_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Actual battle Speed
  #=============================================================================

  alias \
    gv_corruption_pbSpeed \
    pbSpeed

  def pbSpeed
    value =
      gv_corruption_pbSpeed

    return value if
      !corrupted?

    mult =
      GalacticVoidCorruption.
        speed_multiplier(
          corruption_mode
        )

    return [
      (value * mult).round,
      1
    ].max
  end


  #=============================================================================
  # Matching Corruption Cores cannot be stolen
  #=============================================================================

  alias \
    gv_corruption_unlosableItem \
    unlosableItem?

  def unlosableItem?(check_item)
    data =
      GalacticVoidCorruption::
        STONES[
          check_item
        ]

    if data &&
       data[0] == @species

      return true
    end

    return gv_corruption_unlosableItem(
      check_item
    )
  end


  #=============================================================================
  # Revert after fainting
  #=============================================================================

  alias \
    gv_corruption_pbFaint \
    pbFaint

  def pbFaint(showMessage = true)
    ret =
      gv_corruption_pbFaint(
        showMessage
      )

    if @pokemon &&
       @pokemon.corrupted?

      @pokemon.makeUncorrupted
    end

    return ret
  end
end


#===============================================================================
# Battle Corruption System
#
# -1 = Corruption available
# >=0 = Battler selected to Corrupt
# -2 = Trainer already used Corruption
#===============================================================================

class Battle

  #=============================================================================
  # Corruption state
  #=============================================================================

  def corruption
    @corruption ||= [
      [
        -1
      ] * (
        @player ?
        @player.length :
        1
      ),

      [
        -1
      ] * (
        @opponent ?
        @opponent.length :
        1
      )
    ]

    return @corruption
  end


  #=============================================================================
  # Can this battler Corrupt?
  #=============================================================================

  def pbCanCorrupt?(idxBattler)
    battler =
      @battlers[
        idxBattler
      ]

    return false if !battler
    return false if !battler.pokemon
    return false if battler.fainted?
    return false if battler.wild?
    return false if battler.mega?

    return false if
      !battler.hasCorruption?

    if battler.effects[
         PBEffects::SkyDrop
       ] >= 0

      return false
    end

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    return corruption[
      side
    ][owner] == -1
  end


  #=============================================================================
  # Register Corruption
  #=============================================================================

  def pbRegisterCorruption(
    idxBattler
  )
    return false if
      !pbCanCorrupt?(
        idxBattler
      )

    pbUnregisterMegaEvolution(
      idxBattler
    )

    battler =
      @battlers[
        idxBattler
      ]

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    corruption[
      side
    ][owner] =
      idxBattler

    return true
  end


  #=============================================================================
  # Unregister Corruption
  #=============================================================================

  def pbUnregisterCorruption(
    idxBattler
  )
    battler =
      @battlers[
        idxBattler
      ]

    return if !battler

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    if corruption[
         side
       ][owner] ==
       idxBattler

      corruption[
        side
      ][owner] = -1
    end
  end


  #=============================================================================
  # Toggle Corruption
  #=============================================================================

  def pbToggleRegisteredCorruption(
    idxBattler
  )
    battler =
      @battlers[
        idxBattler
      ]

    return false if !battler

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    if corruption[
         side
       ][owner] ==
       idxBattler

      corruption[
        side
      ][owner] = -1

      return false
    end

    return pbRegisterCorruption(
      idxBattler
    )
  end


  #=============================================================================
  # Is this battler registered?
  #=============================================================================

  def pbRegisteredCorruption?(
    idxBattler
  )
    battler =
      @battlers[
        idxBattler
      ]

    return false if !battler

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    return corruption[
      side
    ][owner] ==
      idxBattler
  end


  #=============================================================================
  # Perform Corruption
  #=============================================================================

  def pbCorrupt(idxBattler)
    battler =
      @battlers[
        idxBattler
      ]

    return false if !battler
    return false if !battler.pokemon
    return false if battler.fainted?
    return false if battler.wild?
    return false if battler.mega?

    return false if
      !battler.hasCorruption?

    side =
      battler.idxOwnSide

    owner =
      pbGetOwnerIndexFromBattlerIndex(
        idxBattler
      )

    return false if
      corruption[
        side
      ][owner] !=
      idxBattler


    old_ability =
      battler.ability_id


    data =
      battler.pokemon.
        getCorruptionData


    mode =
      data[1]


    #---------------------------------------------------------------------------
    # Break Illusion like normal Mega Evolution
    #---------------------------------------------------------------------------

    if battler.hasActiveAbility?(
         :ILLUSION
       )

      Battle::AbilityEffects.
        triggerOnBeingHit(
          battler.ability,
          nil,
          battler,
          nil,
          self
        )
    end


    #---------------------------------------------------------------------------
    # Core activation message
    #---------------------------------------------------------------------------

    pbDisplay(
      _INTL(
        "{1}'s {2} is overflowing with corruption!",
        battler.pbThis,
        battler.itemName
      )
    )


    #===========================================================================
    # MEGA EVOLUTION ANIMATION - FIRST HALF
    #===========================================================================

    pbCommonAnimation(
      "MegaEvolution",
      battler
    )


    #---------------------------------------------------------------------------
    # Change into Corruption form
    #---------------------------------------------------------------------------

    return false if
      !battler.pokemon.
        makeCorrupted


    battler.form =
      battler.pokemon.form


    battler.pbUpdate(
      true
    )


    @scene.pbChangePokemon(
      battler,
      battler.pokemon
    )


    @scene.pbRefreshOne(
      idxBattler
    )


    #===========================================================================
    # MEGA EVOLUTION ANIMATION - SECOND HALF
    #===========================================================================

    pbCommonAnimation(
      "MegaEvolution2",
      battler
    )


    #---------------------------------------------------------------------------
    # Corruption result message
    #---------------------------------------------------------------------------

    if mode ==
       GalacticVoidCorruption::VOID

      form_name =
        _INTL(
          "Void Corruption"
        )

    else

      form_name =
        _INTL(
          "Galaxy Corruption"
        )
    end


    pbDisplay(
      _INTL(
        "{1} entered {2}!",
        battler.pbThis,
        form_name
      )
    )


    #---------------------------------------------------------------------------
    # Corruption has now been used
    #---------------------------------------------------------------------------

    corruption[
      side
    ][owner] = -2


    #---------------------------------------------------------------------------
    # Handle changed ability
    #---------------------------------------------------------------------------

    battler.pbOnLosingAbility(
      old_ability
    )


    battler.
      pbTriggerAbilityOnGainingIt


    #---------------------------------------------------------------------------
    # Recalculate turn order
    #---------------------------------------------------------------------------

    if Settings::
       RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION

      pbCalculatePriority(
        false,
        [
          idxBattler
        ]
      )
    end


    return true
  end


  #=============================================================================
  # Corruption HP Drain
  #
  # Both Void and Galaxy lose 1/8 max HP every round.
  #=============================================================================

  def pbCorruptionDrain(
    battler
  )
    return if !battler
    return if battler.fainted?

    return if
      !battler.corrupted?


    hp_loss = [
      battler.totalhp /
      GalacticVoidCorruption::
        DRAIN_DENOMINATOR,

      1
    ].max


    @scene.pbDamageAnimation(
      battler
    )


    battler.pbReduceHP(
      hp_loss,
      false
    )


    pbDisplay(
      _INTL(
        "The corruption sapped {1}'s HP!",
        battler.pbThis(true)
      )
    )


    battler.pbItemHPHealCheck


    battler.pbFaint if
      battler.fainted?
  end


  #=============================================================================
  # Add drain to end-of-round effects
  #=============================================================================

  alias \
    gv_corruption_pbEOREndBattlerSelfEffects \
    pbEOREndBattlerSelfEffects

  def pbEOREndBattlerSelfEffects(
    battler
  )
    gv_corruption_pbEOREndBattlerSelfEffects(
      battler
    )

    pbCorruptionDrain(
      battler
    )
  end


  #=============================================================================
  # Activate Corruption before moves
  #=============================================================================

  def pbAttackPhaseCorruption
    pbPriority.each do |battler|

      next if
        battler.wild?

      next if
        battler.fainted?

      next if
        @choices[
          battler.index
        ][0] !=
        :UseMove


      owner =
        pbGetOwnerIndexFromBattlerIndex(
          battler.index
        )


      next if
        corruption[
          battler.idxOwnSide
        ][owner] !=
        battler.index


      pbCorrupt(
        battler.index
      )
    end
  end


  # Run after normal Mega Evolution processing
  alias \
    gv_corruption_pbAttackPhaseMegaEvolution \
    pbAttackPhaseMegaEvolution

  def pbAttackPhaseMegaEvolution
    gv_corruption_pbAttackPhaseMegaEvolution

    pbAttackPhaseCorruption
  end


  #=============================================================================
  # Prevent Mega + Corruption simultaneously
  #=============================================================================

  alias \
    gv_corruption_pbCanMegaEvolve \
    pbCanMegaEvolve?

  def pbCanMegaEvolve?(
    idxBattler
  )
    battler =
      @battlers[
        idxBattler
      ]

    if battler

      return false if
        battler.corrupted?

      return false if
        pbRegisteredCorruption?(
          idxBattler
        )
    end


    return gv_corruption_pbCanMegaEvolve(
      idxBattler
    )
  end


  #=============================================================================
  # Registering Mega clears pending Corruption
  #=============================================================================

  alias \
    gv_corruption_pbRegisterMegaEvolution \
    pbRegisterMegaEvolution

  def pbRegisterMegaEvolution(
    idxBattler
  )
    pbUnregisterCorruption(
      idxBattler
    )

    gv_corruption_pbRegisterMegaEvolution(
      idxBattler
    )
  end


  #=============================================================================
  # Cancelling Mega also clears pending Corruption
  #=============================================================================

  alias \
    gv_corruption_pbUnregisterMegaEvolution \
    pbUnregisterMegaEvolution

  def pbUnregisterMegaEvolution(
    idxBattler
  )
    gv_corruption_pbUnregisterMegaEvolution(
      idxBattler
    )

    pbUnregisterCorruption(
      idxBattler
    )
  end


  #=============================================================================
  # Reset unfinished selections each command phase
  #=============================================================================

  alias \
    gv_corruption_pbCommandPhase \
    pbCommandPhase

  def pbCommandPhase

    2.times do |side|

      corruption[
        side
      ].each_with_index do |state, owner|

        if state >= 0

          corruption[
            side
          ][owner] = -1
        end
      end
    end


    gv_corruption_pbCommandPhase
  end


  #=============================================================================
  # Battle cleanup
  #
  # Corruption is battle-only.
  #=============================================================================

  alias \
    gv_corruption_pbEndOfBattle \
    pbEndOfBattle

  def pbEndOfBattle

    ret =
      gv_corruption_pbEndOfBattle


    [
      @party1,
      @party2
    ].each do |party|

      next if !party

      party.each do |pkmn|

        next if !pkmn

        if pkmn.corrupted?

          pkmn.makeUncorrupted
        end
      end
    end


    return ret
  end
end