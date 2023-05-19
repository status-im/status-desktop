# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import drivers.SquishDriver as driver
from steps.commonInitSteps import context_init


@OnScenarioStart
def hook(context):
    context_init(context, testSettings)
    context.userData["scenario_name"] = context._data["title"]


@OnScenarioEnd
def hook(context):
    driver.detach()


@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]
