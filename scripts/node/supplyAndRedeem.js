require('dotenv').config();
const { ethers } = require("ethers");

// Configurar el proveedor para la red local
const provider = new ethers.providers.JsonRpcProvider(process.env.SCROLL_SEPOLIA_URL);

// Crear una cartera a partir de la clave privada
const signerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const wallet = new ethers.Wallet(process.env.MY_PRIVATE_KEY, provider);

// Dirección del contrato y su ABI
const contractAddress = require('../../broadcast/DeployScript.s.sol/534351/run-latest.json').transactions[1].contractAddress;
const contractABI = require('../../out/ReFillToken.sol/ReFillToken.json').abi;

// underlying abi
const underlyingABI = require('../../utils/ScrollSepoliaUSDC_abi.json');
// Crear una instancia del contrato
const ReFillToken = new ethers.Contract(contractAddress, contractABI, wallet);
const USDCunderlying = new ethers.Contract('0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D', underlyingABI, wallet);
// Ejemplo de una función de interacción con el contrato
async function interactWithContract() {
    try {
        const amount = ethers.utils.parseUnits("100", 6);
       
        // approve
        let txApprove = await USDCunderlying.approve(ReFillToken.address, amount);
        // supply
        let tx = await ReFillToken.supply(amount);    
        let receipt = await tx.wait();
        
        
        // Crear el mensaje hash
        const nonce = 2;
        const signer = signerWallet.address;
        const to = signer;
        console.log(`to: ${to}`);
        const messageHash = ethers.utils.solidityKeccak256(
            ["address", "uint256", "uint256"],
            [to, amount, nonce]
            );
        // Firmar el mensaje    
        const signature = await signerWallet.signMessage(ethers.utils.arrayify(messageHash));
        
        // redeem 
        tx = await ReFillToken.redeem(to, nonce, amount, signature, {gasLimit:1000000});
        receipt = await tx.wait();
        
        console.log('signature:', signature); 


        console.log("Finalizo");
    } catch (error) {
        console.error("Error:", error);
    }
}

interactWithContract();
