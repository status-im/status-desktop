# -*- coding: utf-8 -*-

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))

import steps.commonInitSteps as init_steps

# This file contains hook functions to run as the .feature file is executed.
#
# A common use-case is to use the OnScenarioStart/OnScenarioEnd hooks to
# start and stop an AUT, e.g.
#
# @OnScenarioStart
# def hook(context):
#     startApplication("addressbook")
#
# @OnScenarioEnd
# def hook(context):
#     currentApplicationContext().detach()
#
# For the complete reference to this and similar available APIs
# (OnFeatureStart/OnFeatureEnd, OnStepStart/OnStepEnd) see the section
# 'Performing Actions During Test Execution Via Hooks' in the Squish manual:
#
# https://doc.qt.io/squish/behavior-driven-testing.html#performing-actions-during-test-execution-via-hooks

# Detach (i.e. potentially terminate) all AUTs at the end of a scenario
@OnScenarioEnd
def hook(context):
    init_steps.driver.detach()

