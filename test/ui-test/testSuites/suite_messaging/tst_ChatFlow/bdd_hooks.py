# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import steps.commonInitSteps as init_steps

# Global properties for the specific feature
_user = "tester123"
_password = "TesTEr16843/!@00"
_chat_room = "test"

@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)  
    init_steps.signs_up_process_steps(context, _user, _password)
    init_steps.the_user_joins_chat_room(_chat_room)

@OnFeatureEnd
def hook(context):
    currentApplicationContext().detach()
    snooze(_app_closure_timeout)
    
@OnScenarioStart
def hook(context):
    init_steps.the_user_opens_the_chat_section()

@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]