all     :; DAPP_BUILD_OPTIMIZE=1 DAPP_BUILD_OPTIMIZE_RUNS=200 dapp --use solc:0.6.12 build
clean   :; dapp clean
test    :; dapp --use solc:0.6.12 test -v
deploy  :; make && dapp create LerpFactory
flatten :; hevm flatten --source-file src/LerpFactory.sol > out/LerpFactory.sol && hevm flatten --source-file src/Lerp.sol > out/Lerp.sol
