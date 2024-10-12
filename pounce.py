from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut
from kitty.boss import Boss
from kitty.window import Window
from typing import List


def is_editor(window: Window) -> bool:
    user_vars = window.user_vars
    if user_vars.get("KITTY_IN_NVIM") is not None:
        return True
    else:
        return False


def encode_keyevent(window: Window, shortcut: str) -> bytes:
    mods, key = parse_shortcut(shortcut)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    return window.encoded_key(event)


def main(args: List[str]) -> str:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    direction = args[1]
    neighbor_window_id = boss.active_tab.neighboring_group_id(direction)
    neighbor = boss.window_id_map.get(neighbor_window_id)
    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return

    if is_editor(window) and len(args) == 3:
        shortcut = args[2]
        for keymap in shortcut.split(">"):
            keyevent = encode_keyevent(window, keymap)
            window.write_to_child(keyevent)
    else:
        boss.active_tab.neighboring_window(direction)
