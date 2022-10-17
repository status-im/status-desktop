
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

# Simulate user input of seed phrase by using mouse to trigger enabled events
def setFocusAndType(input_object_name: str, words: str):
    click_obj_by_name(input_object_name)
    native_type(words)

prevWidth = 0

def did_animation_stopped(item):
    global prevWidth
    res = item.width == prevWidth
    prevWidth = item.width
    return res

def input_seed_phrase(input_object_name: str, seed_phrase: str, with_paste: bool = False):
    global prevWidth
    prevWidth = 0
    words = seed_phrase.split()
    verify(len(words) == 12 or len(words) == 18 or len(words) == 24, "Seed phrase should have 12, 18 or 24 words")
    # After switching from the default layout of 12 words to 18 or 24 words,
    # the inputs are animated and in motion, so we need to wait for them to settle otherwise
    # the input will be sent to the wrong input field.
    firstInput = wait_and_get_obj(input_object_name + str(1))
    do_until_validation_with_timeout(lambda: sleep_test(0.2), lambda: did_animation_stopped(firstInput), f'Waiting until animation stops', 2000)
    if with_paste:
        click_obj_by_name(input_object_name + str(1))
        copy_to_clipboard(seed_phrase)
        execute_paste_sequence()
    else:
        for(i, word) in enumerate(words, start=1):
            setFocusAndType(input_object_name + str(i), word)
