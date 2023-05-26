# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import steps.commonInitSteps as init_steps


@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)  
    context.userData['aut'] = []

@OnScenarioEnd
def hook(context):
    [ctx.detach() for ctx in squish.applicationContextList()]
    
@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]