# -*- coding: utf-8 -*-

#******************************************************************************
# Status.im
#*****************************************************************************/
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

   
@Given("the application is restarted")
def step(context):
    currentApplicationContext().detach()
    startApplication("nim_status_client")
  
    
@When("user inputs the following |any| with object locator |any|")
def step(context, text, obj):
    input_text(text, obj)


@Then("the following object locator |any| is not enabled")
def step(context, obj):
    object_not_enabled(obj)
