#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    StatusProcess.py
# *
# * \date    February 2022
# * \brief   Base template class to define testing status processes.
# *****************************************************************************/
 
class StatusProcess:
    __context = None
    # Variable used to determine if it is needed to verify the process success or the process failure behavior
    __verify_success: bool = True
               
    def __init__(self, context):
        self.__context = context
        
    # It is used to check if the process can be run 
    #@abstractmethod  
    def can_execute_process(self):
        print("TODO: Invoke needed screen/s constructors")
        # ***
        # Below, the code to create the necessary status screen to execute the process.
        # ***
                    
    # It is used to execute the specific status process steps.
    #@abstractmethod
    def execute_process(self, verify_success: bool = True):
        self.__verify_success = verify_success
        print("TODO: Invoke navigations")
        # ***
        # Below, the code to invoke the necessary status screen's navigations.
        # ***
    
    # It is used to obtain the status process output result.
    #@abstractmethod
    def get_process_result(self):
        result = False
        result_description = None
        
        print("TODO: Validate process steps")
        # ***
        # Below, the code to validate status process steps.
        # ***
        
        return result, result_description