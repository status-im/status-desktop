import time
from enum import Enum
from drivers.SquishDriver import *
from drivers.SquishDriverVerification import *

class LanguageSettings(Enum):
    MAIN_VIEW: str = "settings_LanguageView"
    LIST_PICKER: str = "languageView_language_StatusListPicker"
    PICKER_BUTTON: str = "languageView_language_StatusPickerButton"
    LIST_VIEW: str = "languageView_language_ListView"
    SEARCHER_INPUT: str = "languageView_language_StatusInput"

class StatusLanguageScreen:
    
    def is_screen_loaded(self):
        verify(is_loaded_visible_and_enabled(LanguageSettings.MAIN_VIEW.value), "Checking Language & Currency view is displayed.") 
        
    def open_language_combobox(self):
        click_obj_by_name(LanguageSettings.LIST_PICKER.value)
        
    def select_language(self, language: str):
        [found, language_obj] = self._scroll_and_find_language(language)
        if found:
            return click_obj(language_obj)       
        return verify(found, "Checking if language found: " + language)
    
    def search_language(self, language: str):
        [loaded, language_list] = is_loaded(LanguageSettings.LIST_VIEW.value)
        initial_count = language_list.count
        wait_for_object_focused_and_type(LanguageSettings.SEARCHER_INPUT.value, language)
        filtered_count = language_list.count        
        verify(loaded and filtered_count < initial_count, "Checking if searcher filters something")        
        
        
    def verify_current_language(self, language: str):           
        obj = get_obj(LanguageSettings.PICKER_BUTTON.value)        
        verify_text(str(obj.text), language)
        
    def _scroll_and_find_language(self, language):
        [loaded, language_list] = is_loaded(LanguageSettings.LIST_VIEW.value)
        if not loaded: 
            return False, None       
        else:                
            for index in range(language_list.count): 
                # First scroll at specific index to be sure it is visible and it is possible to get its content:
                if scroll_list_view_at_index(language_list, index):                
                    # Get the object, it is already visible and loaded: 
                    language_obj = language_list.itemAtIndex(index)
                             
                    if(language_obj.shortName == language):
                        return True, language_obj