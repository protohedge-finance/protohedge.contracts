../deploy/deploy-all-contracts.sh
./transfer-usdc.sh 0x809d550fca64d94bd9f66e60752a544199cfac3d 10000000
cd ../../../protohedge.rebalancer
until ENV_FILE=local python3 main.py 
do
    echo "Trying again"    
done

 
