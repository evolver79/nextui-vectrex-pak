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
3. In a game, open the menu, pick the overlay under **Overlay**, and save the settings for that game. NextUI reads the
   file when you pick it, so after changing an overlay file, pick it again (or restart the game).

### Making them fit the Brick

The images in those collections are portrait pictures of just the Vectrex screen, in all sizes, and most are solid
colour. Used as they are they don't line up and hide the game. What works on the Brick:

- **Canvas:** 1024×768, transparent. NextUI stretches the overlay over the whole screen.
- **Placement:** stretch the overlay to **618×768 at x=203, y=0**. That's where the game picture sits (vecx's 33:41
  aspect ratio with the default Aspect scaling), so the overlay's frame matches the edges of the picture.
- **Opacity:** for overlays that are solid in the middle, about **25%**. The lines take the zone's colour and the
  background gets a dark tint, close to the real plastic. At 35% the lines look dull; lower and the colour fades.
  Overlays that already have a see-through middle (most 3D Imager ones, for example) can stay as they are.

[`tools/fit-overlay.swift`](tools/fit-overlay.swift) does all three on macOS (no extra installs):

```sh
swiftc -O -o fit-overlay tools/fit-overlay.swift
./fit-overlay scramble.png "Scramble (World).png"         # 25% by default
./fit-overlay scramble.png "Scramble (World).png" 0.3     # or another opacity
```

Run it over a whole folder and name each result after its ROM. Not every game has an overlay in these collections
(Polar Rescue and Pole Position don't, nor do most prototypes).

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
