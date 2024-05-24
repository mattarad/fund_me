-include .env

deploy-sep: forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEP_API_KEY) --private-key $(PRIV_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv