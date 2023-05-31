# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import steps.commonInitSteps as init_steps

# Global properties for the specific feature
_user = "tester123"
_password = "TesTEr16843/!@00"
_chat_room1 = "search-automation-test-1"
_chat_room2 = "search-automation-test-2"
_community_name = "myCommunity"
_community_description = "My community description"
_community_intro = "Community Intro"
_community_outro = "Commmunity Outro"
_channel_name = "automation-community"
_channel_description = "My description"
_method = "bottom_menu"

@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)  
    init_steps.signs_up_process_steps(context, _user, _password)
    init_steps.the_user_joins_chat_room(_chat_room1)
    init_steps.the_user_joins_chat_room(_chat_room2)
    init_steps.the_user_opens_the_community_portal_section()
    init_steps.the_user_lands_on_the_community_portal_section()
    init_steps.the_user_creates_a_community(_community_name, _community_description, _community_intro, _community_outro)
    init_steps.the_user_lands_on_the_community(_community_name)
    init_steps.the_admin_creates_a_community_channel(_channel_name, _channel_description, _method)
    init_steps.the_channel_is_open(_channel_name)

@OnFeatureEnd
def hook(context):
    init_steps.driver.detach()
    
@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]