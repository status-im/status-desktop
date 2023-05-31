# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed
import time

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../shared/steps/"))

import steps.commonInitSteps as init_steps

# Global properties for the specific feature
_user = "tester123"
_password = "TesTEr16843/!@00"


@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)


@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]


@OnScenarioStart
def hook(context):
    context.userData['aut'] = []


@OnScenarioEnd
def hook(context):
    init_steps.driver.detach()
                