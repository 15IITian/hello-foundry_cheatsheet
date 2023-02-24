# hello-foundry

https://book.getfoundry.sh/

- [ ] install

```shell
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

- [ ] init

```shell
forge init
```

- [ ] basic commands - compile and test
- [ ] solc version and optimizer settings
- hello world
  - [ ] fmt
  - [ ] test

```shell
forge fmt
forge test --match-path test/HelloWorld -vvvv
```

- test (match, test ok, fail, verbose, gas report)

  - counter app
  - match
  - test ok, failure
  - verbose
  - gas report

```shell
forge test --match-path test/Counter.t.sol -vvv --gas-report
```

- console

```shell
forge test --match-path test/Console.t.sol -vv
```

- [ ] auth
- [ ] event (expectEmit)
- [ ] test error (expectRevert)
- [ ] time
- [ ] test label for error
- [ ] send eth
  - [ ] deal, hoax
- [ ] signature
- cheatcode
- remapping
```shell
forge remappings
forge install rari-capital/solmate
```
- test multisig?
- mainnet fork
- crosschain fork
- [ ] fuzzing
- invariant
- differential testing

- formatter
- chisel
- debugger

# TODO:

- [ ] std storage
- tutorials
- refs
- vyper?
