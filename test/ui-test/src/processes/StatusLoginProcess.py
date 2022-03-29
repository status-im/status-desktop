#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    StatusLoginProcess.py
# *
# * \date    February 2022
# * \brief   It defines the status login process.
# *****************************************************************************/

from processes.StatusProcess import StatusProcess
from screens.StatusLoginScreen import StatusLoginScreen
from screens.StatusLoginScreen import PswPlaceholderTextType

# It defines the status login process.
class StatusLoginProcess(StatusProcess):
    __login_screen = None
    __account = None
    __byKeycard = False
    __isBiometrics = False
    __step1_result = False
    __step2_result = False
    __step3_result = False
               
    def __init__(self, account, isBiometrics=False):
        self.__account = account
        self.__byKeycard = (account.get_password() == None)
        self.__isBiometrics = isBiometrics     
     
    # It is used to check if the process can be run   
    def can_execute_process(self):         
        # Create current screen and verify if it is correctly loaded
        self.__login_screen = StatusLoginScreen()
        return self.__login_screen.is_loaded()   
               
    # It is used to execute the status login process steps.
    def execute_process(self, verify_success = True):
        self.__verify_success = verify_success 
        
        if(self.__account.get_password()):
            self.__execute_password_steps()
        else:
            raise NotImplementedError("TODO: __execute_keycard_steps")
        
    # It is used to obtain the status login process output result.
    def get_process_result(self):
        result = False
        result_description = None
        
        # Login by password:
        if(self.__account.get_password()):             
            if not self.__step1_result:
                result_description = "Not possible to select the given account."
             
            elif not self.__step2_result:
                result_description = "Not possible to introduce given password and submit."
                
            elif not self.__step3_result and self.__verify_success:
                result_description = "Expected connection to Status Desktop failed."
                
            elif not self.__step3_result and not self.__verify_success:
                result_description = "Expected error message not shown."
                
            else:
                # All the steps have been correctly executed.
                result = True 
                result_description = "Process steps succeeded!"       
        
        # Login by keycard:
        else:
            raise NotImplementedError("TODO: __execute_keycard_steps")
               
        return result, result_description
    
    # Step 1 - The user selects an account
    # Step 2 - The user enters a password
    # Step 3 - Verify login success / failure
    def __execute_password_steps(self):           
        
        # Step 1:            
        self.__step1_result = self.__step_user_selects_account(self.__account.get_name())
         
        # Step 2:
        self.__step2_result = self.__step_user_enters_password(self.__account.get_password())
        
        # Step 3:
        if self.__verify_success:
            self.__step3_result = self.__verify_login_success()
        else:
            self.__step3_result = self.__verify_login_failure()
     
    # It navigates through login screen to select the given account:
    def __step_user_selects_account(self, accountName):        
        result = False
        if self.__login_screen and self.__login_screen.is_loaded():
            if self.__login_screen.open_accounts_selector_popup():
                accounts_popup = self.__login_screen.get_accounts_selector_popup()
                if accounts_popup.is_loaded():
                    result = accounts_popup.select_account(accountName)
        return result
       
    # It navigates through password input and submits the introduced one:     
    def __step_user_enters_password(self, password): 
        res1 = False
        res2 = False
        if self.__login_screen and self.__login_screen.is_loaded():
            res1 = self.__login_screen.introduce_password(password)
            res2 = self.__login_screen.submit_password()
            
        return res1 & res2
    
    # It inspects login screen and decides if login has been succeed:
    def __verify_login_success(self):
        res1 = False
        res2 = False
        if self.__login_screen and self.__login_screen.is_loaded():
            res1 = self.__login_screen.get_password_placeholder_text() == PswPlaceholderTextType.CONNECTING.value
            res2 = self.__login_screen.get_error_message_text() == ""
        return res1 & res2
    
    # It inspects login screen and decides if it displays the expected failure information:  
    def __verify_login_failure(self):
        result = False
        if self.__login_screen and self.__login_screen.is_loaded():
            result = self.__login_screen.get_error_message_text() == self.__login_screen.get_expected_error_message_text()
        return result
        