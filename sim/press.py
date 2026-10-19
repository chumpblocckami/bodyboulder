"""Send key presses to the Connect IQ simulator window and screenshot it.

Usage: uv run --with python-xlib press.py OUT.png KEY [KEY ...]
Keys are X keysym names (Return, Escape, Up, Down, ...), "wait:SECONDS",
or "click:X,Y" in simulator-window pixels.
"""

import subprocess
import sys
import time

from Xlib import X, XK, display, protocol
from Xlib.ext import xtest

TITLE = "CIQ Simulator"


def find_window(d: display.Display):
    """Return the simulator's client window, or None if it is not open."""
    stack = [d.screen().root]
    while stack:
        w = stack.pop()
        name = w.get_wm_name()
        if isinstance(name, str) and name.startswith(TITLE) and w.get_wm_class() == ("simulator", "Simulator"):
            return w
        stack.extend(w.query_tree().children)
    return None


def main() -> None:
    """Focus the simulator, send the requested keys, and save a screenshot."""
    out, keys = sys.argv[1], sys.argv[2:]
    d = display.Display()
    win = find_window(d)
    if win is None:
        sys.exit("simulator window not found")
    # The window manager ignores input to a window it has not activated itself.
    root = d.screen().root
    activate = protocol.event.ClientMessage(
        window=win, client_type=d.intern_atom("_NET_ACTIVE_WINDOW"), data=(32, [2, X.CurrentTime, 0, 0, 0])
    )
    root.send_event(activate, event_mask=X.SubstructureRedirectMask | X.SubstructureNotifyMask)
    d.sync()
    time.sleep(0.3)
    for key in keys:
        if key.startswith("wait:"):
            time.sleep(float(key[5:]))
            continue
        if key.startswith("click:"):
            x, y = (int(v) for v in key[6:].split(","))
            pos = d.screen().root.translate_coords(win, x, y)
            xtest.fake_input(d, X.MotionNotify, x=pos.x, y=pos.y)
            xtest.fake_input(d, X.ButtonPress, 1)
            d.sync()
            time.sleep(0.15)
            xtest.fake_input(d, X.ButtonRelease, 1)
            d.sync()
            time.sleep(0.8)
            continue
        code = d.keysym_to_keycode(XK.string_to_keysym(key))
        xtest.fake_input(d, X.KeyPress, code)
        xtest.fake_input(d, X.KeyRelease, code)
        d.sync()
        time.sleep(0.6)
    time.sleep(0.8)
    subprocess.run(["import", "-window", hex(win.id), out], check=True)


if __name__ == "__main__":
    main()
