# ETH/USDC Trading

An implementation using ChainLink and OpenZeppelin's library for allow user to deposit ETH and exchange for USDC as well as withdrawing the funds

## Tests

### Run the following

```shell
npm install
npx hardhat test
```

### If you would like to see the gas report

```shell
REPORT_GAS=true npx hardhat test
```

### If you would like to only run some specific tests

#### To run all the tests in a specific file

```shell
npx hardhat test <path_to_the_test_file>
```

#### To run only a specific unit test

Add ```.only``` after the ```it``` of your specific choice in the test file

For example:

```typescript
it.only("Should open a long position correctly", async function () {
    // the test code
});
```
