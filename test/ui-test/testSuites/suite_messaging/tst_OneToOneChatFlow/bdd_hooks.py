# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

# from steps.chatSteps import *

# Global properties for the specific feature
_user = "tester123"
_password = "TesTEr16843/!@00"
_data_folder_path = "../../../fixtures/mutual_contacts"

@OnFeatureStart
def hook(context):
    context_init(context)
    login_process_steps(context, _user, _password, _data_folder_path)

@OnFeatureEnd
def hook(context):
    currentApplicationContext().detach()
    snooze(_app_closure_timeout)
    
@OnScenarioStart
def hook(context):
    when_the_user_opens_the_chat_section()
    
@OnScenarioEnd
def hook(context):
    leave_current_chat()

@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]