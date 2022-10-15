all     :; forge build --use solc:0.6.12 --optimize --optimizer-runs 200
clean   :; forge clean
test    :; forge test -vvv
deploy  :; make && forge create LerpFactory
flatten :; forge flatten --output out/LerpFactory.flattened.sol src/LerpFactory.sol
