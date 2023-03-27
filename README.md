# FVM-Smart-Notary

## Brief Description
A Smart Notary Protocol to ease client onbording to Filecoin network and incentivize notaries to earn rewards making due diligence on clients 

## General Overview

The goal of the Smart-Notary is to make the "clients" (organizations who want to store data on Filecoin network) onboarding smoother, prevent fraudulent behaviors from notaries and incentive them to participate and do the due diligence work needed ot onboard the clients.
To do so, Filecoin has a token called DataCap who is issued by Filecoin and used by clients to make deals.

## How It Works: Flow
1. Notaries presents a new client **staking some FIL** as a warrantee for clients behavior in Filecoin network.
2. When at least 2 notaries "ensure" the client staking FIL, Smart Notary Actor take care of the creation of the "Smart Client Actor" and grant it an initial amount of Datacap tokens.
3. When the Smart Client is running out of datacap, it can send a "refill request" to the Smart Notary Actor.
5. When the Smart-Notary receives a top-up request, if the conditions are met* it grant the next round of DataCap.
6. Notaries who staked FIL to ensure the client receive fee everytime a new allocation happens.

*:see next paragraph

## Conditions to allocate new dataCap
The conditions are defined through a module which is linked to the SMart-Notary contract. Those conditions represent the rules defined by the community to allow new datacap allocations

## Components
Smart Notary Actor: a smart contract who is in charge of accepting new notaries in the protocol, allows these to present and support clients on filecoin network and grant datacap

Smart Client Actor: A smart contract who allow the owner to make deals in filecoin network using DataCap tokens granted by the Smart Notary Acotr.
It holds information about the smart client owner, the DataCap balance and the notaries supporting it.

Rule Module: A smart contract which allows the Smart Notary Actor to check if a Smart Client Actor is following the community rules.

Rules: Smart contracts defined by the rules following the same interafe. Those are checked by the Rule Module.

## Flow Diagram
![Schermata 2023-02-05 alle 15 09 15](https://user-images.githubusercontent.com/46995085/216824406-1c0758cd-1fff-4179-a63d-bd574fa8fdcb.png)

