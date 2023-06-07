# -*- coding: utf-8 -*-
# This file contains hook functions to run as the .feature file is executed

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../shared/steps/"))

import steps.commonInitSteps as init_steps
import walletInitSteps as wallet_init_steps

# Global properties for the specific feature
_user = "tester123"
_password = "qqqqqqqqqq"
_seed_phrase = "pelican chief sudden oval media rare swamp elephant lawsuit wheat knife initial"

@OnFeatureStart
def hook(context):
    init_steps.context_init(context, testSettings)
    init_steps.signs_up_with_seed_phrase_process_steps(context, _seed_phrase, _user, _password)
    wallet_init_steps.open_wallet()

@OnFeatureEnd
def hook(context):
    init_steps.driver.detach()
    
@OnStepEnd
def hook(context):
    context.userData["step_name"] = context._data["text"]
