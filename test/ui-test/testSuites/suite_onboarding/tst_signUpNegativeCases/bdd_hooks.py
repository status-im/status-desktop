# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import steps.commonInitSteps as init_steps

# Global properties for the specific feature
_user = "tester123"
_onboarding_new_psw_input = "onboarding_newPsw_Input"

@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)  
    init_steps.a_first_time_user_lands_on_and_generates_new_key(context)

@OnFeatureEnd
def hook(context):
    init_steps.driver.detach()

@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]
    
@OnScenarioEnd
def hook(context):
    # Scenario cleanup
    init_steps.the_user_navigates_back_to_user_profile_page()