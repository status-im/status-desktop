
from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *
from drivers.SDKeyboardCommands import *
from common.Common import *


class SearchPopupComponents(Enum):
    SEARCH_INPUT = "searchPopupSearchInput_TextEdit"
    SEARCH_RESULT_LISTVIEW = "searchPopup_Result_ListView"
    RESET_BUTTON = "searchPopup_Reset_Button"
    LOADING_INDICATOR = "searchPopup_Loading_Indicator"

class StatusSearchScreen:
    def __init__(self):
        self._loading_done_retries = 0

    def open_search_menu(self):
        if sys.platform == "darwin":
            native_type("<Command+f>");
        else:
            native_type("<Ctrl+f>");
    
    def _do_wait_for_loading_done(self):
        # Wait 10 seconds for the loading to be over, if more, throw
        if (self._loading_done_retries > 10):
            verify_failure("The loading indicator for the search is not going away")
        [indicator_visible, _] = is_loaded_visible_and_enabled(SearchPopupComponents.LOADING_INDICATOR.value, 1000)
        if (indicator_visible):
            self._loading_done_retries += 1
            self.wait_for_loading_done()
            
    def wait_for_loading_done(self):
        self._loading_done_retries = 0
        self._do_wait_for_loading_done()

    def search_for(self, search_term: str):
        click_obj_by_name(SearchPopupComponents.RESET_BUTTON.value)
        type(SearchPopupComponents.SEARCH_INPUT.value, search_term)
        self.wait_for_loading_done()
        
    def verify_number_of_results(self, amount: int):
        list_view = get_obj(SearchPopupComponents.SEARCH_RESULT_LISTVIEW.value)
        verify_values_equal(str(list_view.count), str(amount), "Not the right amount of search results were found")
        
    def click_on_channel(self, channel_name: str):
        list_view = get_obj(SearchPopupComponents.SEARCH_RESULT_LISTVIEW.value)
        channel_item = None
        found = False
        for index in range(list_view.count):
            channel_item = list_view.itemAtIndex(index)
            if(channel_item.title == channel_name):
                found = True
                break
        if (not found):
            verify_failure("Channel not found in the search field, name: " + channel_name)
            
        click_obj(channel_item)
        
    def click_on_message(self, message: str):
        list_view = get_obj(SearchPopupComponents.SEARCH_RESULT_LISTVIEW.value)
        message_item = None
        found = False
        for index in range(list_view.count):
            message_item = list_view.itemAtIndex(index)
            if(message in str(message_item.subTitle)):
                found = True
                break
        if (not found):
            verify_failure("Message not found in the search field, message: " + message)
            
        click_obj(message_item)
        