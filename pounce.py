from kittens.tui.handler import result_handler
from kitty.key_encoding import KeyEvent, parse_shortcut
from kitty.boss import Boss
from kitty.window import Window
from typing import List


def is_nvim(window: Window) -> bool:
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


def send_keyevent(window: Window, shortcut: str) -> None:
    for keymap in shortcut.split(">"):
        keyevent = encode_keyevent(window, keymap)
        window.write_to_child(keyevent)


def main(args: List[str]) -> str:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    target = boss.window_id_map.get(target_window_id)
    if target is None:
        return

    if is_nvim(target) and len(args) == 3:
        shortcut = args[1]
        send_keyevent(target, shortcut)
    else:
        direction = args[2]
        neighbor_window_id = boss.active_tab.neighboring_group_id(direction)
        neighbor = boss.window_id_map.get(neighbor_window_id)
        if neighbor is None:
            return

        boss.active_tab.windows.set_active_group(neighbor_window_id)
        if is_nvim(neighbor):
            shortcut = args[1]
            send_keyevent(neighbor, shortcut)
