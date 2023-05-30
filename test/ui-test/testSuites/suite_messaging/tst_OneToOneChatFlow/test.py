source(findFile('scripts', 'python/bdd.py'))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../testSuites/global_shared/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../src/"))
sys.path.append(os.path.join(os.path.dirname(__file__), "../shared/steps/"))
setupHooks('../../global_shared/scripts/bdd_hooks.py')
collectStepDefinitions('./steps', '../shared/steps/', '../../global_shared/steps/', '../../suite_onboarding/shared/steps/')

import configs


def main():
    testSettings.throwOnFailure = True
    configs.path.TMP.mkdir(parents=True, exist_ok=True)
    runFeatureFile('test.feature')
    configs.path.TMP.rmtree(ignore_errors=True)
