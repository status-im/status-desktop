import configs.system

# Buttons
BACKSPACE = 'Backspace'
COMMAND = 'Command'
CTRL = 'Ctrl'
ESCAPE = 'Escape'
RETURN = 'Return'
SHIFT = 'Shift'

# Combinations
SELECT_ALL = f'{CTRL if configs.system.IS_WIN else COMMAND}+A'
OPEN_GOTO = f'{COMMAND}+{SHIFT}+G'
