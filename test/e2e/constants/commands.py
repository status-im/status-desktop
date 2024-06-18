from configs import system

# Buttons
BACKSPACE = 'Backspace'
COMMAND = 'Command'
CTRL = 'Ctrl'
ESCAPE = 'Escape'
RETURN = 'Return'
SHIFT = 'Shift'

# Combinations
SELECT_ALL = f'{CTRL if system.get_platform() == "Windows" else COMMAND}+A'
OPEN_GOTO = f'{COMMAND}+{SHIFT}+G'
