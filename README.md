# Vectrex pak for NextUI

Adds the GCE Vectrex (1982) to [NextUI](https://github.com/LoveRetro/NextUI), using the libretro
[vecx](https://github.com/libretro/libretro-vecx) core. The Vectrex system ROM (with Mine Storm) is built into the core,
so no BIOS is needed.

Tested on the TrimUI Brick (`tg5040`).

## Install

**Pak Store:** look for Vectrex under Emulators.

**By hand:** download `VECTREX.pak.zip` from [Releases](../../releases) and unzip it into a new folder on the SD card,
`Emus/tg5040/VECTREX.pak/`.

## Games

Put games (`.vec` or `.bin`) in `Roms/Vectrex (VECTREX)/`. The folder name can be anything, but the tag in brackets must
be `VECTREX`. The lines are drawn white; see Overlays for colour.

## Overlays

Each Vectrex game came with its own coloured plastic overlay for the screen. This pak doesn't include any (the artwork
isn't ours to share), but NextUI can show them:

1. Get overlay images, for example from
   [raphkoster/vectrex-overlays](https://github.com/raphkoster/vectrex-overlays),
   the GCE Vectrex set in [libretro/overlay-borders](https://github.com/libretro/overlay-borders), or
   [cosmo0/retropie-overlays](https://github.com/cosmo0/retropie-overlays) (`_sources/games/vectrex`).
2. Put the PNGs in `Overlays/VECTREX/` on the SD card. Naming them after the ROM (`Scramble (World).png`) makes them
   easy to find.
3. In a game, open the menu, pick the overlay under **Overlay**, and save the settings for that game.

NextUI draws the overlay over the whole 1024×768 screen, while the game picture sits in the middle, about 617×768. Images
made for RetroArch (often 1920×1080) may need resizing or cropping first to line up.

## Controls

| Vectrex | Brick |
|---|---|
| Joystick | D-pad |
| Button 1 | B |
| Button 2 | A |
| Button 3 | Y |
| Button 4 | X |

Change them in the in-game menu.

## Building

```sh
./build-core.sh    # builds VECTREX.pak/vecx_libretro.so from source in an ARM64 Docker container
./package.sh       # writes dist/VECTREX.pak.zip
```

The core is built from [libretro-vecx](https://github.com/libretro/libretro-vecx) at the commit in `build-core.sh`,
with `patches/vecx-rgb565.patch`, in Debian bullseye (glibc 2.31, the Brick has 2.33):

- `HAS_GPU=0`: software rendering only, so it needs no libGL (the Brick has none, and the stock build won't load).
- RGB565 output: NextUI's minarch doesn't support the 0RGB1555 the stock core uses, which gives a black screen.

Building needs Docker on an ARM64 machine (Apple Silicon works natively). The built core is committed, so releases ship
the build that was tested.

Pushing a tag `vX.Y.Z` that matches `version` in `pak.json` makes a GitHub release with the zip attached.

## License

The pak's own files are MIT ([LICENSE](LICENSE)). The vecx core is GPLv3 ([LICENSE-vecx](LICENSE-vecx)); the release zip
includes the license. Its source is https://github.com/libretro/libretro-vecx plus the patch in `patches/`.
