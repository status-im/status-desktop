source(findFile('scripts', 'python/bdd.py'))

setupHooks('../../global_shared/scripts/bdd_hooks.py')
collectStepDefinitions('./steps', '../shared/steps/', '../../global_shared/steps/', '../../suite_onboarding/shared/steps/', '../../suite_messaging/shared/steps/')


def main():
    testSettings.throwOnFailure = True
    runFeatureFile('test.feature')
