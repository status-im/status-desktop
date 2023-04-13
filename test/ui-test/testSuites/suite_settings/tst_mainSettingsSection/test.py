source(findFile('scripts', 'python/bdd.py'))

setupHooks('bdd_hooks.py')
collectStepDefinitions('./steps', '../shared/steps/', '../../global_shared/steps/', '../../suite_onboarding/shared/steps/')

def main():
    testSettings.throwOnFailure = True
    testSettings.logScreenshotOnError = True
    testSettings.logScreenshotOnFail = True
    runFeatureFile('test.feature')
