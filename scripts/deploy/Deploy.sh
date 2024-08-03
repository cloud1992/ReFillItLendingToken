
# bash scripts/deploy/Deploy.sh --network scroll_sepolia arbitrum_sepolia

set -e # Exit immediately if a command exits with a non-zero status.

SCRIPT_DIR=$(dirname "$0:A")
ENV_REL_PATH="/../../.env"

source "${SCRIPT_DIR}${ENV_REL_PATH}"  # source .env file

# Check if at least one network is specified
if [ $# -eq 0 ]; then
    echo "Missing fork networks"
    exit 1
fi

# Iterate over all arguments
networks=()

for arg in "$@"
do
    if [ "$arg" = "--network" ]; then
        continue
    fi

    if [ "$arg" = "scroll_sepolia" ]; then
        rpc_url="${SCROLL_SEPOLIA_URL}"
        network="scroll_sepolia"
        networkU="ScrollSepolia"
    elif [ "$arg" = "arbitrum_sepolia" ]; then
        rpc_url="${ARBITRUM_SEPOLIA_RPC_URL}"
        network="arbitrum_sepolia"
        networkU="ArbitrumSepolia"
    else
        echo "Wrong fork network: $arg"
        exit 1
    fi

    # Deploy to the current network
    FOUNDRY_PROFILE=deploy forge script "${SCRIPT_DIR}/../../deploy/DeployScript.s.sol:Deploy${networkU}" --rpc-url $rpc_url --optimize --broadcast --verify --json --slow  --gas-estimate-multiplier 200  --gas-limit 10000000

    networks+=("$network")
done