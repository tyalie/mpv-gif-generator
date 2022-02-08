# MPV GIF generator script

Small script that uses ffmpeg in order to generate GIFs from a choosen part the playing video.
It's adapted and improved from https://gist.github.com/Ruin0x11/8fae0a9341b41015935f76f913b28d2a.


## Installation

This script requires ffmpeg and mpv installed. It probably also only works on linux right now due to how paths are handled.

Copy the lua script into 
- `~/.config/mpv/scripts/` for you or
- `/etc/mpv/scripts` to install it for all users

## Usage

| shortcut          | effect                    |
| ----------------- | ------------------------- |
| <kbd>g</kbd>      | set gif start             |
| <kbd>G</kbd>      | set gif end               |
| <kbd>Ctrl+g</kbd> | render gif                |
| <kbd>Ctrl+G</kbd> | render gif with subtitles |

**Note:** Rendering of gifs with subtitles is a bit limited as only non-bitmap ones are currently supported and the generation can take quite long when the file is in a network share or similar.

The output is currently written to `/tmp/` in the format `/tmp/<VIDEO NAME>_000.gif`
