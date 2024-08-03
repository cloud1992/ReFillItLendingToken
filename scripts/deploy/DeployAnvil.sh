# You must have anvil running locally with a fork 

# bash scripts/deploy/startAnvilChains.sh scroll_sepolia

# run this script like this:
# bash scripts/deploy/DeployAnvil.sh --fork scroll_sepolia



set -e # Exit immediately if a command exits with a non-zero status.

SCRIPT_DIR=$(dirname "$0:A")
ENV_REL_PATH="/../../.env"

source "${SCRIPT_DIR}${ENV_REL_PATH}"  # source .env

# Check if at least one network is specified
if [ $# -eq 0 ]; then
    echo "Missing fork networks"
    exit 1
fi

# Iterate over all arguments
networks=()

for arg in "$@"
do
    if [ "$arg" = "--fork" ]; then
        continue
    fi

    if [ "$arg" = "arbitrum_sepolia" ]; then
        fork="ArbitrumSepolia"
        fork_url=$LOCAL_RPC_URL_ETH
        
    elif [ "$arg" = "scroll_sepolia" ]; then
        fork="ScrollSepolia"
        fork_url=$LOCAL_RPC_URL_SCROLL_SEPOLIA
                 
    else
        echo "Wrong fork network: $arg"
        exit 1
    fi

    # Deploy to the current network
    FOUNDRY_PROFILE=deploy forge script "${SCRIPT_DIR}/../../deploy/DeployScript.s.sol:Deploy${fork}" --fork-url ${fork_url} --optimize --broadcast 

    

    networks+=("$network")
done



 
