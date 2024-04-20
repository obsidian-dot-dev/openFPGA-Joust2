# Joust 2

Joust 2 (Williams 6809 "rev 2") compatible openFPGA core the Analogue Pocket.

Based on the FPGA Joust2/Inferno/Mystic Marathon/Turkey Shoot cores by Dar, and ported from the following MiSTer core repos:
* [Joust 2](https://github.com/MiSTer-devel/Arcade-Joust2_MiSTer) by birdybro and Dar
* [Inferno](https://github.com/MiSTer-devel/Arcade-Inferno_MiSTer) by birdybro and JasonA
* [Turkey Shoot](https://github.com/MiSTer-devel/Arcade-TurkeyShoot_MiSTer) by birdybro
* [Mystic Marathon](https://github.com/MiSTer-devel/Arcade-MysticMarathon_MiSTer) by birdybro and JasonA

Note that the original cores are all very similar - this core refactors all of these into a single core supporting the individual board variants' minor differences.

## Compatibility

This core supports the arcade games running on the Williams 6809 "Rev 2" arcade board. The list of games includes:

* Joust 2 - Survival of the Fittest
* Inferno
* Turkey Shoot - The Day They Took Over
* Mystic Marathon

Note that arcade games supported by earlier Williams "Rev 1" (i.e. Defender, Joust, etc.) 6809 board are *not* supported by this core - but are supported in the following cores:
* [Defender/Early Rev 1](https://github.com/obsidian-dot-dev/openFPGA-Defender)
* [Robotron/Late Rev 1](https://github.com/obsidian-dot-dev/openFPGA-Robotron)

## Service Mode Controls

Buttons for service-mode controls (for the high-score-reset and in-game service menu) are mapped as follows:

* Advance -- Select + L
* Auto-up -- Select + up
* Reset High Scores -- Select + R

## Inferno - "Diagnoal Control" Mode

Inferno features dual joystics, offset at 45-degrees (similar to Q-bert) for both movement and aiming.  This doesn't translate amazingly-well to the Analogue Pocket d-pad, which is not very precise in the diagonals.  

Disabling the Diagonal Controls option in the interact menu allows the user to toggle between using the diagonal controls on the d-pad/buttons or mapping the raw Up/Down/Left/Right directions to Up-right, down-left, up-left, and down-right respsectively.

By default, the Diagonal Controls option is set.

## Inferno - "Auto-fire on Aim" mode

Inferno's joysticks support movement and aiming - but firing is accomplished through a dedicated button which is mounted to the top of the "aim" joystick.  This is mapped to the R-button on the Pocket by default.  However, enabling "Auto-fire on Aim" results in the fire button being pressed automatically when any direction on the "aim" joystick is active.

By default, Auto-Fire on Aim is set.

## Inferno - Analog Controls

Users with dual-analog joysticks are able to use the twin-sticks for control and aim, without additional configuration.  Analog sticks operate in Diagonal mode, regardless of the "Diagonal Control" interact menu setting.

## Turkey Shoot

Turkey Shoot uses an X/Y encoder-based light gun in the original arcade machine.  The movement of the gun is simulated using the d-pad on the Analogue Pocket.  A single-pixel crosshair represents the gun's aiming position on screen.

When the "Fast Aim" button is held (mapped to the R trigger by default), the crosshairs move across the screen twice as fast as the default speed. This allows for more precise control when needed - the targets are indeed very small on the Pocket's screen.

## Usage

*No ROM files are included with this release.*  

Install the contents of the release to the root of the SD card.

Place the necessary `.rom` files for the supported games onto the SD card under `Assets/joust2/common`.

To generate the `.rom` format binaries used by this core, you must use the MRA files included in this repo, along with the corresponding ROMs from the most recent MAME release.

## History

v0.9.0
* Initial Release.

## Attribution

```
---------------------------------------------------------------------------------
-- Williams by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
-- https://sourceforge.net/projects/darfpga/files
-- github.com/darfpga
---------------------------------------------------------------------------------
-- gen_ram.vhd & io_ps2_keyboard
-------------------------------- 
-- Copyright 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)z
-- http://www.syntiac.com/fpga64.html
---------------------------------------------------------------------------------
-- cpu09l - Version : 0128
-- Synthesizable 6809 instruction compatible VHDL CPU core
-- Copyright (C) 2003 - 2010 John Kent
---------------------------------------------------------------------------------
-- cpu68 - Version 9th Jan 2004 0.8
-- 6800/01 compatible CPU core 
-- GNU public license - December 2002 : John E. Kent
---------------------------------------------------------------------------------
-- MC6809
-- Copyright (c) 2016, Greg Miller
---------------------------------------------------------------------------------
-- HC55516/HC55564 Continuously Variable Slope Delta decoder
-- (c)2015 vlait
---------------------------------------------------------------------------------
-- JT51 (YM2151). <http://www.gnu.org/licenses/>.
-- Author: Jose Tejada Gomez. Twitter: @topapate
---------------------------------------------------------------------------------
```

See individual modules for details.