# -*- coding: utf-8 -*-

#******************************************************************************
# Status.im
#*****************************************************************************/
#/**
# * \file    steps.py
# *
# * \test    Status Desktop - Login
# * \date    February 2022
# * \brief   This file contains snippets of script code to be executed as the .feature
# *          file is processed.
# *          The decorators Given/When/Then/Step can be used to associate a script snippet
# *          with a pattern which is matched against the steps being executed.
# *****************************************************************************
from data.StatusAccount import StatusAccount 
from processes.StatusLoginProcess import StatusLoginProcess    

@Given("A Status Desktop |any| and |word|")
def step(context,account,password):
    
    # Create new data domain:
    accountObj = StatusAccount(account, password) 
    
    # Create new process:
    process = StatusLoginProcess(accountObj) 
    
    # Set needed context properties:  
    context.userData['process'] = process
    context.userData['account'] = accountObj
    
    # Verify process can be executed:
    test.verify(process.can_execute_process(), "Not possible to start login process. Check if expected Login Screen is available.")
    
@When("the user tries to login with valid credentials")
def step(context):
    loginProcess = context.userData['process']
    
    # Check valid process behavior:
    loginProcess.execute_process(True)

@When("the user tries to login with invalid credentials")
def step(context):
    loginProcess = context.userData['process']
    
    # Check invalid process behavior:
    loginProcess.execute_process(False)

@Then("the user is able to login to Status Desktop application")
def step(context):
    get_process_result(context)
    
@Then("the user is NOT able to login to Status Desktop application")
def step(context):
    get_process_result(context)
  
# Common:
def get_process_result(context):
    loginProcess = context.userData['process']
    result, description = loginProcess.get_process_result()
    test.verify(result, description)
