## Deploy USDV on Sepolia

```shell
forge script script/DeployUsdvToken.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY
```

to simulate

```shell
forge script script/DeployUsdvToken.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY --broadcast
```

## Mint USDV for a particular user

```shell
cast send 0x2aF3c4E3a6ee455294693B977a2D3DABf419B3B5 "mint(address,uint256)" 0xB63cE207B985e8508b17B5e8CF3900EF22C4e444 50000000 --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY
```

if any issue with these commands, you can add : _--legacy_ options


Address USDV deployed on Sepolia : 0x2aF3c4E3a6ee455294693B977a2D3DABf419B3B5

## Deploy NFT Collection on Sepolia

```shell
forge script script/DeploySdvNft.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY --broadcast
```

if any issue with these commands, you can add : _--legacy_ options

## Mint USDV for a particular user

```shell
cast send <NFT_Smartcontract_address> "mint(address,string)" 0xB63cE207B985e8508b17B5e8CF3900EF22C4e444 "https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/1337.png" --rpc-url $SEPOLIA_RPC_URL --private-key $SEPOLIA_PRIVATE_KEY
```

Address NFT SC deployed : 0xa727E67fFf460be1D40E638481C034F1836140F6

## TP

1. Le système de vote devra possèder un workflow de vote avec les étapes suivantes :

   - Enregistrement des candidats
   - Donation par des donateurs aux candidats
   - Vote
   - Comptage des voix

   Seul l'administrateur définit les étapes du vote et lorsqu'une étape est passée on ne peut plus executer la fonction correspondante

2. Ceci sera soumis à la création de ROLES :

   - 1 Role d'admin du SC
   - 1 Role "Funders"
   - 1 Role de "Voters"

3. Les funders ne peuvent payer qu'avec la crypto créée précédemment

4. Les voters ne peuvent voter que s'ils sont proprietaires d'un NFT de la collection de NFT précédemment créée

5. Tests unitaires

# Web3 Learning platforms

 - Alchemy University
 - Chainlink YT Channel
 - Free Code Camp
 - Cyfrin Updraft
 - Patrick Collins YT Channel
 - Ben BK YT Channel
