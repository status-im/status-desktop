# -*- coding: utf-8 -*-

import time

# ******************************************************************************
# Status.im
# *****************************************************************************/
# /**
# * \file    steps.py
# *
# * \test    Status Desktop - Login
# * \date    February 2022
# * \brief   This file contains snippets of script code to be executed as the .feature
# *          file is processed.
# *          The decorators Given/When/Then/Step can be used to associate a script snippet
# *          with a pattern which is matched against the steps being executed.
# *****************************************************************************
import common.Common as common
import steps.commonInitSteps as init_steps
import drivers.SquishDriver as driver
from screens.StatusChatScreen import StatusChatScreen
from screens.StatusMainScreen import StatusMainScreen

_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()


#########################
### PRECONDITIONS region:
#########################

@Given("the user starts the application with a specific data folder \"|any|\"")
def step(context, data_folder_path):
    init_steps.a_user_starts_the_application_with_a_specific_data_folder(context, data_folder_path)


@Given("the user restarts the app")
def step(context):
    the_user_restarts_the_app(context)


@Given("the user joins chat room \"|any|\"")
def step(context, room):
    the_user_joins_chat_room(room)


@Given("the user clicks on escape key")
def step(context):
    _statusMain.click_escape()


@Given("the user clears input \"|any|\"")
def step(context, input_component):
    common.clear_input_text(input_component)


@Given("the user inputs the following \"|any|\" with ui-component \"|any|\"")
def step(context, text, obj):
    the_user_inputs_the_following_text_with_uicomponent(text, obj)


@Given("the user clicks on the following ui-component \"|any|\"")
def step(context: any, obj: str):
    the_user_clicks_on_the_following_ui_component(obj)


#########################
### ACTIONS region:
#########################

@When("the user restarts the app")
def step(context):
    the_user_restarts_the_app(context)


@When("the user inputs the following \"|any|\" with ui-component \"|any|\"")
def step(context, text, obj):
    the_user_inputs_the_following_text_with_uicomponent(text, obj)


@When("the user clicks on the following ui-component \"|any|\"")
def step(context: any, obj: str):
    init_steps.the_user_clicks_on_the_following_ui_component(obj)


@When("the user joins chat room \"|any|\"")
def step(context, room):
    the_user_joins_chat_room(room)


# TODO remove when we have a reliable local mailserver
@When("the user waits |any| seconds")
def step(context, amount):
    time.sleep(2)


#########################
### VERIFICATIONS region:
#########################

@Then("the following ui-component \"|any|\" is not enabled")
def step(context, obj):
    common.object_not_enabled(obj)


###########################################################################
### COMMON methods used in different steps given/when/then region:
###########################################################################

def the_user_restarts_the_app(context: any):
    driver.detach()
    driver.start_application(clear_user_data=False)


def the_user_joins_chat_room(room: str):
    init_steps.the_user_joins_chat_room(room)


def the_user_inputs_the_following_text_with_uicomponent(text: str, obj):
    common.input_text(text, obj)


def the_user_clicks_on_the_following_ui_component(obj):
    init_steps.the_user_clicks_on_the_following_ui_component(obj)
