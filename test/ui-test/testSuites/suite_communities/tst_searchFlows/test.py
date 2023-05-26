source(findFile('scripts', 'python/bdd.py'))


setupHooks('bdd_hooks.py')
collectStepDefinitions('./steps', '../shared/steps/', '../../global_shared/steps/', '../../suite_messaging/shared/steps/')

import configs


def main():
    testSettings.throwOnFailure = True
    configs.path.TMP.mkdir(parents=True, exist_ok=True)
    runFeatureFile('test.feature')
    configs.path.TMP.rmtree(ignore_errors=True)
    