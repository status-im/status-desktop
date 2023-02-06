# Developer helpers to run ganache dependent test cases locally

Ganache is used in tests to avoid depending on RPC internet calls

In CI ganache is started as a docker container directly from the [test suite](../../../../../ci/Jenkinsfile.e2e) (see stage `Containers`). In order to run locally you need to start ganache manually with the same options as Jenkins environment.

## How to run e2e tests locally

Optionally edit [`.env`](./.env) file to match your personal setup if the defaults don't work for you. The file is loaded by `desktop-compose` from the run step.

Running

- Compile to include the squish specific configuration like this `GANACHE_NETWORK_RPC_URL="http://localhost:9545" make -j10`
  - This is required because `GANACHE_NETWORK_RPC_URL` is a `const` Nim variable and cannot be changed at runtime (`make clean` if binary is already built without the `GANACHE_NETWORK_RPC_URL`)
  - Upon this step the production `NETWORKS` configuration in `status-desktop/src/app_service/common/network_constants.nim` is overridden with the second pair that includes the `GANACHE_NETWORK_RPC_URL` variable for all nodes along with specific token contract override for `SNT` and `STT`
- Start ganache docker environment `docker-compose up uitestganache`
- Run squish desired tests (if all is setup correctly, you should see RPC output calls in the `docker-compose up` output)

**Beware** that the default `.env` will alter the in sources test data. Using the in-sources test data folder makes it is easy to add changes to the git index.

- Solution: a copy of the `<status-desktop>/test/ui-test/fixtures/ganache-dbs/goerli` can be made outside sources and docker-compose redirected to use a personal `.env` file (using the `--env-file` option) pointing to the personal clone of the test data folder.
