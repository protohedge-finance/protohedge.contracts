../deploy/deploy-all-contracts.sh
./transfer-usdc.sh 0xfa4d1950831e0ae5bec5663419b5a7bf50f7175b 10000000
cd ../../../protohedge.rebalancer
until ENV_FILE=local python3 main.py 
do
    echo "Trying again"    
done

 
