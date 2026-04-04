# Purpose of the protocol
Building the standard that turns blockchain transactions into compliant financial records. Financial data 
is broken between crypto and accounting.
The goal of this protocol is to automate the missing part between a transaction and its financially compliant expression,
ie accounting data.

## Initial problematic situation
The initial idea stems from 2 ends:
- The difficulty for builders to get paid in crypto. Bad payers are legion in the industry, whereas the 
technology is there to limit the effects of their behavirous. Namely escrow.
- Reconciling on-chain payments - salaries, grants, service fees - with real-world accounting is a pain, especially if you avoid centralised exchanges.

## Use case
The cleanest use case: 
- Payer creates an escrow contract, with all necessary data embedded: duration of contract,
amount paid to builder, date, etc.
- Payer whether funds the contract through his own treasury OR borrows money from a lending protocol (Morpho/Aave). Funding a project through financing is a very widespread use case in the real world.
- Payee delivers project or services and payer releases the money from the contract
- Protocol generates tax-related data, digestible by mainstream accounting software (Quickbooks, Xero, Pennylane)

## Supporting tech stack
Main tech: Arc Network. Fast settlement in USDC. 
Swapping tokens: Uniswap
Naming and clean UX: ENS
Financing: Aave or Morpho

## CLI vs UI
We chose to be agent-ready with a clean CLI, simplifying the development process but also enabling composability, automation and agent-powered processes. 

## North Star Vision
This protocol can become the financial data layer for Web3. 