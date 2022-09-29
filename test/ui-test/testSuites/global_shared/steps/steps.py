# -*- coding: utf-8 -*-

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
from common.Common import *
import time

from screens.StatusMainScreen import StatusMainScreen
from screens.StatusChatScreen import StatusChatScreen

_statusMain = StatusMainScreen()
_statusChat = StatusChatScreen()

@Given("the user starts the application with a specific data folder |any|")
def step(context, data_folder_path):
    waitFor(lambda: currentApplicationContext().detach(), 500)
    time.sleep(5)
    clear_directory(context.userData["status_data_folder_path"])
    copy_directory(data_folder_path, context.userData["status_data_folder_path"])
    startApplication(context.userData["aut_name"])

@When("the user restarts the app")
def step(context):
    waitFor(lambda: currentApplicationContext().detach(), 500)
    time.sleep(5)
    startApplication(context.userData["aut_name"])
    
@When("user inputs the following |any| with ui-component |any|")
def step(context, text, obj):
    input_text(text, obj)


@When("user clicks on the following ui-component |any|")
def step(context, obj):
    click_on_an_object(obj)

@When("user joins chat room |any|")
def step(context, room):
    _statusMain.join_chat_room(room)
    _statusChat.verify_chat_title(room)


@Then("the following ui-component |any| is not enabled")
def step(context, obj):
    object_not_enabled(obj)