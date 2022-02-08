# MPV GIF generator script

Small script that uses ffmpeg in order to generate GIFs from a chosen part the playing video.
It's adapted and improved from https://gist.github.com/Ruin0x11/8fae0a9341b41015935f76f913b28d2a.


## Installation

This script requires ffmpeg and mpv installed. It probably also only works on Linux right now due to how paths are handled.

Copy the lua script into 
- `~/.config/mpv/scripts/` for you or
- `/etc/mpv/scripts` to install it for all users

### Debugging

If errors with ffmpeg occurs these are either logged to the terminal (when `terminal != no`) otherwise to `/tmp/mpv-gif-ffmpeg.<TIMESTAMP>.log`. The `terminal==no` case occurs for example when
starting mpv through the `*.desktop` entry (i.e. file explorer, …)

## Usage

| shortcut          | effect                    |
| ----------------- | ------------------------- |
| <kbd>g</kbd>      | set gif start             |
| <kbd>G</kbd>      | set gif end               |
| <kbd>Ctrl+g</kbd> | render gif                |
| <kbd>Ctrl+G</kbd> | render gif with subtitles |

**Note:** Rendering of gifs with subtitles is a bit limited as only non-bitmap ones are currently supported and the generation can take quite long when the file is in a network share or similar.

The output is currently written to `/tmp/` in the format `/tmp/<VIDEO NAME>_000.gif`

## Configurations
The script can be configured either by having a `script-opts/gifgen.conf` or using e.g. `--script-opts=gifgen-width=-1`. An example configuration file could be:

```conf
width=480
height=-1  # automatically determine height
outputDirectory=~/  # gif output directory
```
