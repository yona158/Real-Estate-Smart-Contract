# Real Estate Smart Contract

## Description
This project is a decentralized application (dApp) for managing real estate properties on the Ethereum blockchain. Built using **Solidity**, **Truffle**, and **Ganache**, it allows users to register properties, list them for sale, buy properties, and handle transactions with government approval. The smart contract ensures secure and transparent property transactions, with features like tax calculations, refund mechanisms, and property ownership tracking.

## Features
**Property Registration:** Register properties with details like location, price, and owner.
**Property Listing:** List properties for sale or remove them from the market.
**Buy Property:** Users can buy properties, with payments requiring government approval.
**Government Approval:** The government can approve or reject property sales.
**Tax Calculation:** A 2% tax is deducted from each sale and transferred to the government.
**Refund Mechanism:** Buyers can request refunds if the sale is rejected.
**Property Details:** Retrieve detailed information about any property.

## Prerequisites
Before running the project, ensure you have the following installed:
**1- Node.js** (v16.x or later)
**2-Truffle** (npm install -g truffle)
**3-Ganache** (Download from [Ganache](https://trufflesuite.com/ganache/))
**4-MetaMask** (Optional, for interacting with the dApp)

# Setup Instructions

### 1. Clone the Repository
```
git clone https://github.com/yona158/Real-Estate-Smart-Contract.git
cd Real-Estate-Smart-Contract
```

### 2. Install Dependencies
Install the required Node.js packages:
```
npm install
```

### 3. Start Ganache
- Open Ganache and click **"Quickstart"** to launch a local Ethereum blockchain.
- Note the **RPC Server** URL (usually http://127.0.0.1:7545).

### 4. Configure Truffle
Ensure your truffle-config.js file is configured to connect to Ganache:
```
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
  },
  compilers: {
    solc: {
      version: "0.8.21",
    },
  },
};
```

### 5. Compile and Deploy the Contract
Compile and deploy the smart contract to Ganache:
```
truffle migrate --network development
```

### 6. Interact with the Contract
You can interact with the contract using **Truffle Console**:
```
truffle console --network development
```

### File Structure
```
project/
├── contracts/
│   ├── Migrations.sol
│   └── RealEstate.sol
├── migrations/
│   ├── 1_initial_migration.js
│   └── 2_deploy_contracts.js
├── test/
│   └── (Test files)
├── truffle-config.js
└── README.md
```

## Testing
To run tests, use the following command:
```
truffle test
```

## License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

## Contributing
Contributions are welcome! Please open an issue or submit a pull request.

## Contact
For questions or feedback, contact me at [bayan.jess998@gmail.com].
