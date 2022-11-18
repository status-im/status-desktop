source(findFile('scripts', 'python/bdd.py'))

setupHooks('bdd_hooks.py')
collectStepDefinitions('./steps', '../shared/steps/', '../../global_shared/steps/')


def main():
    testSettings.throwOnFailure = True
    runFeatureFile('test.feature')
