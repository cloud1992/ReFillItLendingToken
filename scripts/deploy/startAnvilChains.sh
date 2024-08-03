# run this script like this:
# bash scripts/deploy/startAnvilChains.sh scroll_sepolia ... any desired supported chain


pkill anvil  # Kill all processes with 'pkill anvil'

set -e  # Exit immediately if a command exits with a non-zero status.

SCRIPT_DIR=$(dirname "$0:A")
ENV_REL_PATH="/../../.env"

source "${SCRIPT_DIR}${ENV_REL_PATH}"  # source .env

# Iterate over all arguments
for arg in "$@"
do
    if [ "$arg" = "arbitrum_sepolia" ] || [ "$arg" = "main" ]; then
        anvil --fork-url "${ARBITRUM_SEPOLIA_RPC_URL}" --port 8547 
        
    elif [ "$arg" = "scroll_sepolia" ]; then
        anvil --fork-url "${SCROLL_SEPOLIA_URL}" --port 8546 
        
    else
        echo "Wrong fork network: $arg"
        exit 1
    fi

done

