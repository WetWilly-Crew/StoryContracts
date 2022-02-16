//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

contract RoughWaters {
    // TODO:
    //  - name,
    //  - pronouns,
    //  - ERC20 address,
    //  - ERC1155 address,
    //  - ERC721 address
    //  - Sequences complétées
    //  - Choix
    //  - Scores d'affinité
    //  - Stats
    mapping(address => string) private _names;
    mapping(address => string) private _pronouns;
    mapping(address => mapping(uint256 => uint256)) _affinities;
    mapping(address => mapping(uint256 => uint256)) _stats;
    address Coins;
    address Items;
    address Collection;
    address Story;


    constructor() {
    }
}
