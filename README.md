# IPv4-Escrow - Not Properly Tested yet - please do not use!
The IPv4-Escrow is a Smart Contract designed to act as an escrow service for IPv4 subnet Buy/Sell transactions. It includes three main roles:

- Seller: The party that sells the IPv4 subnet to the buyer.
- Buyer: The party that acquires the IPv4 subnet from the seller.
- Broker: The party that sets up the contract, API keys, subnet source and destination data, etc.

## Contract Outcomes
The contract can have two possible outcomes:

- Success: The Decentralized Oracle Network confirms that the subnet is allocated to the buyer. The seller receives the deposited amount excluding gas and broker fees, the buyer receives the confirmed IP subnet ownership, and the broker receives fees.
- Failure: If the Decentralized Oracle Network is unable to confirm the subnet transfer within the time set by the broker, the buyer receives a refund excluding gas and broker fees, and the seller keeps the subnet.

## Algorithm
The algorithm for the IPv4-Escrow Contract involves the following steps:

1. The Broker sets up the contract with the following parameters:
   - Broker fees
   - IPv4 subnet information
   - Seller org-id
   - Buyer org-id
   - Transfer timeout
   - Deal activation timeout
   - Amount of the deal
   - Seller address
   - Buyer address
2. The Buyer deposits the required amount to the smart contract.
3. The Seller activates the deal. If the deal is not activated by a seller during the deal activation timeout, the deal is reversed (see Failure scenario).
4. The Seller attempts to withdraw funds. Withdrawal will require the contract to check the status of the subnet. It costs gas that is deducted from the contract's funds. Once the status is changed to ready to withdraw, the seller receives the funds, and no further subnet status updates are possible.

## Failsafe
The deal may be cancelled (Failure scenario) or approved (Success scenario) if corresponding measures are confirmed by all parties involved in the contract: buyer, seller, and broker.
