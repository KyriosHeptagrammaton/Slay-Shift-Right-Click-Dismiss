# Slay — Shift+Right-Click Dismiss

A small patch for **Slay 5.0u** (Sean O'Connor, windowsgames.co.uk) that lets you put back a unit or castle you are holding.

In the original game, if you buy a castle (keep) and there is nowhere legal to place it, you are stuck holding it — a soft-lock. This patch adds a way out.

## What it changes

| | Right-click | **Shift + right-click** |
|---|---|---|
| Empty hand | Buys a peasant (unchanged) | Does nothing |
| Man in hand | Upgrades him (unchanged) | **Puts him back** — refunds what you paid, or returns a man you picked up to his hex |
| Castle in hand | Nothing (unchanged) | **Puts it back** and refunds the 15 gold |

It uses the game's own undo, so everything is restored exactly as it was before you picked the item up. If a castle is in your hand right after loading a saved game (no undo history), it is removed and the 15 gold refunded. A man in that situation is left alone, because the game can't tell whether he was bought or picked up; you can always place him in your own territory.

## Install

1. Download this repository (green **Code** button → **Download ZIP**) and unzip it.
2. Copy `Install.bat`, `patch.ps1` and `Uninstall.bat` into your Slay folder, next to `Slay.exe`.
3. Double-click **Install.bat**. If Slay is under Program Files, it will ask for administrator permission.

The installer:
- only patches Slay 5.0u (`Slay.exe`, 577,536 bytes, SHA-256 `E590D95CDBD9D202EDC692BD42F114A775629439D5EB5903FF3225F5F23BD019`) and refuses anything else;
- keeps your original as `Slay_original.exe`;
- checks the patched file is byte-for-byte correct before replacing `Slay.exe`.

To undo, run **Uninstall.bat**.

## How it works

The patch hooks the game's right-mouse-button-up handler. If Shift is held (`MK_SHIFT` in the message's `wParam`), it repeatedly calls the game's built-in undo until your hand is empty, then reuses the game's own "item dropped back" redraw. Otherwise it falls through to the original code. The hook lives in unused padding at the end of the program's code section. Assembly source is in [`src/cave_shift.s`](src/cave_shift.s).

This repository does not contain any of Slay's own files — you need your own copy of the game.
