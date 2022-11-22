# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

from steps.commonInitSteps import context_init

@OnScenarioStart
def hook(context):
    context_init(context, testSettings)

@OnScenarioEnd
def hook(context):
    currentApplicationContext().detach()
    snooze(_app_closure_timeout)

@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]