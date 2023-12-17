# Development integration tests for status-go

These integration tests are an experiment. They rely on an existing developer environment (working user folder, blockchain access tokens) and internet connection.

If it proves its usefulness we might consider automating them and make it independent of internet services

## How to run tests

Setup steps

- Dump the node config passed to `Login` status-go call as `.node_config.json` and use its path later on in as `nodeConfigFile` in `.integration_tests_config.json`
  - Ensure the blockchain access tokens are configured when dumping the configuration file
- Copy [integration_tests_config-template.json](./integration_tests_config-template.json) to tests sub-folders and rename it as `.integration_tests_config.json`, then update it with your own values.
  - Update `nodeConfigFile` with the previously extracted node config path
  - The `hashedPassword` should be the "0x" + `keccak256(clearPassword)`
  - For `dataDir` it is expected an working status-go user folder (e.g. the usual `status-desktop/Second/data` used with `make run` command)

Run wallet tests

- once

  ```sh
  (cd test/status-go/integration && go test -count=1 -v ./wallet/... --tags=gowaku_no_rln,gowaku_skip_migrations)
  ```

- continuously on code changes

  ```sh
  (cd test/status-go/integration && nodemon --watch ../../../vendor/status-go/ --watch .  --ext "*.go,*.sql" --exec 'go test -count=1 -v ./wallet/... --tags=gowaku_no_rln,gowaku_skip_migrations 2>&1 | tee ~/proj/tmp/status-go-tests.log || exit 1')
  ```
