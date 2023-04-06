
@Then("the Secure Your Seed Phrase Banner is not displayed")
def step(context):
    StatusMainScreen().is_secure_your_seed_phrase_banner_visible(False)