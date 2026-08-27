#===============================================================================
# Pokemon Galactic Void - Corruption Core
# Pokemon Essentials v21.1
#===============================================================================

module GalacticVoidCorruption
  VOID   = :VOID
  GALAXY = :GALAXY

  # Keep Corruption forms away from existing
  # Mega/regional/alternate forms.
  VOID_FORM   = 10
  GALAXY_FORM = 11

  # Format:
  # ITEM => [
  #   SPECIES,
  #   MODE,
  #   NORMAL FORM,
  #   CORRUPTION FORM
  # ]
  #
  # Form 10 = Void Corruption
  # Form 11 = Galaxy Corruption

  STONES = {

    #=======================================================================
    # BOTH VOID + GALAXY
    #=======================================================================

    :OBLIVIXVOIDCORE => [
      :OBLIVIX,
      VOID,
      0,
      VOID_FORM
    ],

    :OBLIVIXSTARCORE => [
      :OBLIVIX,
      GALAXY,
      0,
      GALAXY_FORM
    ],

    :ERUPTILEVOIDCORE => [
      :ERUPTILE,
      VOID,
      0,
      VOID_FORM
    ],

    :ERUPTILESTARCORE => [
      :ERUPTILE,
      GALAXY,
      0,
      GALAXY_FORM
    ],

    :MORTARINEVOIDCORE => [
      :MORTARINE,
      VOID,
      0,
      VOID_FORM
    ],

    :MORTARINESTARCORE => [
      :MORTARINE,
      GALAXY,
      0,
      GALAXY_FORM
    ],

    :GALLADEVOIDCORE => [
      :GALLADE,
      VOID,
      0,
      VOID_FORM
    ],

    :GALLADESTARCORE => [
      :GALLADE,
      GALAXY,
      0,
      GALAXY_FORM
    ],


    #=======================================================================
    # GALAXY ONLY
    #=======================================================================

    :GARCHOMPSTARCORE => [
      :GARCHOMP,
      GALAXY,
      0,
      GALAXY_FORM
    ],

    :HYDREIGONSTARCORE => [
      :HYDREIGON,
      GALAXY,
      0,
      GALAXY_FORM
    ],


    #=======================================================================
    # VOID ONLY
    #=======================================================================

    :GENGARVOIDCORE => [
      :GENGAR,
      VOID,
      0,
      VOID_FORM
    ],

    :FLAREONVOIDCORE => [
      :FLAREON,
      VOID,
      0,
      VOID_FORM
    ],

    :SWAMPERTVOIDCORE => [
      :SWAMPERT,
      VOID,
      0,
      VOID_FORM
    ],

    :ELECTIVIREVOIDCORE => [
      :ELECTIVIRE,
      VOID,
      0,
      VOID_FORM
    ],

    :LUCARIOVOIDCORE => [
      :LUCARIO,
      VOID,
      0,
      VOID_FORM
    ],

    :KINGAMBITVOIDCORE => [
      :KINGAMBIT,
      VOID,
      0,
      VOID_FORM
    ],

    :CERULEDGEVOIDCORE => [
      :CERULEDGE,
      VOID,
      0,
      VOID_FORM
    ],

    :HARIYAMAVOIDCORE => [
      :HARIYAMA,
      VOID,
      0,
      VOID_FORM
    ],

    :MACHAMPVOIDCORE => [
      :MACHAMP,
      VOID,
      0,
      VOID_FORM
    ],

    :METAGROSSVOIDCORE => [
      :METAGROSS,
      VOID,
      0,
      VOID_FORM
    ],

    :GOLURKVOIDCORE => [
      :GOLURK,
      VOID,
      0,
      VOID_FORM
    ],

    :SABLEYEVOIDCORE => [
      :SABLEYE,
      VOID,
      0,
      VOID_FORM
    ],

    :AGGRONVOIDCORE => [
      :AGGRON,
      VOID,
      0,
      VOID_FORM
    ],

    :TYRANTRUMVOIDCORE => [
      :TYRANTRUM,
      VOID,
      0,
      VOID_FORM
    ],

    :RHYPERIORVOIDCORE => [
      :RHYPERIOR,
      VOID,
      0,
      VOID_FORM
    ],

    :URSHIFUVOIDCORE => [
      :URSHIFU,
      VOID,
      0,
      VOID_FORM
    ],

    :BANETTEVOIDCORE => [
      :BANETTE,
      VOID,
      0,
      VOID_FORM
    ],

    :VICTREEBELVOIDCORE => [
      :VICTREEBEL,
      VOID,
      0,
      VOID_FORM
    ],

    :VIKAVOLTVOIDCORE => [
      :VIKAVOLT,
      VOID,
      0,
      VOID_FORM
    ],

    :VOLCARONAVOIDCORE => [
      :VOLCARONA,
      VOID,
      0,
      VOID_FORM
    ],

    :WAILORDVOIDCORE => [
      :WAILORD,
      VOID,
      0,
      VOID_FORM
    ],

    :TYRANITARVOIDCORE => [
      :TYRANITAR,
      VOID,
      0,
      VOID_FORM
    ],

    :MAWILEVOIDCORE => [
      :MAWILE,
      VOID,
      0,
      VOID_FORM
    ]

  }

  DRAIN_DENOMINATOR = 8

  #-----------------------------------------------------------------------------
  # Gets the Corruption Stone data for this Pokemon.
  #-----------------------------------------------------------------------------

  def self.stone_data(pkmn)
    return nil if !pkmn

    data = STONES[pkmn.item_id]

    return nil if !data
    return nil if pkmn.species != data[0]

    return data
  end


  #-----------------------------------------------------------------------------
  # Checks that the required form actually exists.
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Stat multipliers
  #-----------------------------------------------------------------------------

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

    data = getCorruptionData

    return false if !data

    # Must be in the correct normal form.
    return false if
      form_simple != data[2]

    # The corrupted form must exist.
    return GalacticVoidCorruption.form_exists?(
      data[0],
      data[3]
    )
  end


  def makeCorrupted
    data = getCorruptionData

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


  #-----------------------------------------------------------------------------
  # Attack
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Special Attack
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Defense
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Special Defense
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Raw Speed
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Actual battle turn-order Speed
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Corruption Stones can't be stolen from their proper species.
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Revert if the Pokemon faints.
  #-----------------------------------------------------------------------------

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
# -1 = Corruption hasn't been used
# >=0 = Battler selected to Corrupt this turn
# -2 = Trainer has already used Corruption
#===============================================================================

class Battle

  #-----------------------------------------------------------------------------
  # Corruption state
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Can this battler Corrupt?
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Register Corruption
  #-----------------------------------------------------------------------------

  def pbRegisterCorruption(
    idxBattler
  )
    return false if
      !pbCanCorrupt?(
        idxBattler
      )

    # One Pokemon can't select Mega and
    # Corruption at the same time.
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


  #-----------------------------------------------------------------------------
  # Unregister Corruption
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Toggle Corruption
  #-----------------------------------------------------------------------------

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


  #-----------------------------------------------------------------------------
  # Is this battler registered to Corrupt?
  #-----------------------------------------------------------------------------

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
  # Actually Corrupt
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
    # Break Illusion, like Mega Evolution does.
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
    # Transformation message
    #---------------------------------------------------------------------------

    pbDisplay(
      _INTL(
        "{1}'s {2} is overflowing with corruption!",
        battler.pbThis,
        battler.itemName
      )
    )


    #---------------------------------------------------------------------------
    # Placeholder animation.
    # Later we'll replace this with a custom Corruption animation.
    #---------------------------------------------------------------------------

    pbCommonAnimation(
      "MegaEvolution",
      battler
    )


    #---------------------------------------------------------------------------
    # Change form
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


    pbCommonAnimation(
      "MegaEvolution2",
      battler
    )


    #---------------------------------------------------------------------------
    # Void/Galaxy message
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
    # This trainer has now used Corruption.
    #---------------------------------------------------------------------------

    corruption[
      side
    ][owner] = -2


    #---------------------------------------------------------------------------
    # Trigger changed ability if the Corrupted form has one.
    #---------------------------------------------------------------------------

    battler.pbOnLosingAbility(
      old_ability
    )

    battler.
      pbTriggerAbilityOnGainingIt


    #---------------------------------------------------------------------------
    # Recalculate priority because Void changes Speed.
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
  # Both Void and Galaxy lose 1/8 maximum HP every round.
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


  #-----------------------------------------------------------------------------
  # Add the drain to the real v21.1 end-of-round phase.
  #-----------------------------------------------------------------------------

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
  # Activate Corruption before attacks.
  #=============================================================================

  def pbAttackPhaseCorruption
    pbPriority.each do |battler|

      next if battler.wild?

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


  alias \
    gv_corruption_pbAttackPhaseMegaEvolution \
    pbAttackPhaseMegaEvolution

  def pbAttackPhaseMegaEvolution
    gv_corruption_pbAttackPhaseMegaEvolution

    pbAttackPhaseCorruption
  end


  #=============================================================================
  # Prevent one Pokemon from Mega Evolving and Corrupting simultaneously.
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


  #-----------------------------------------------------------------------------
  # pbCancelChoice in Essentials already unregisters Mega Evolution.
  # By hooking this, cancelling a command also unregisters Corruption.
  #-----------------------------------------------------------------------------

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
  # Reset unfinished selections at the beginning of each command phase.
  #
  # -2 remains untouched because that means Corruption has already been used.
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
  # Corruption is battle-only and must never remain after the battle ends.
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