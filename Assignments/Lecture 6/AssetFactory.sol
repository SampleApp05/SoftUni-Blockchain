// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

error DuplicateAsset();
error InvalidAddress();
error IncorrectAmount();
error AssetNotFound();

contract Asset  {
    string public name;
    string public ticker;
    uint256 public supply;
    address public owner;

    mapping(address => uint256) holders;

    constructor(string memory name_, string memory ticker_, uint256 initialSupply_) {
        name = name_;
        ticker = ticker_;
        supply = initialSupply_ * 1 ether;
    }

    function transferTo(address target, uint256 amount) external payable {
        if (msg.value > supply) { revert IncorrectAmount(); }
        supply = supply - amount;
        
        holders[target] += amount;
    }

    function balanceOf(address target) public view returns (uint256) {
        if (target == address(0)) { revert InvalidAddress(); }
        return holders[target];
    }
}

contract AssetFactory {
    mapping(string => address) public assets;

    function createAsset(string memory name, string memory ticker, uint256 initialSupply) public {
        if (assets[ticker] != address(0)) revert DuplicateAsset();

        address newAssetAddress = address(new Asset(name, ticker, initialSupply));
        assets[ticker] = newAssetAddress;
    }

    function send(address target, string memory assetTicker, uint256 amount) external payable {
        if (target == address(0)) { revert InvalidAddress(); }
        if (amount == 0) { revert IncorrectAmount(); }

        address assetAddress = assets[assetTicker];
        if (assetAddress == address(0)) { revert AssetNotFound(); }

        Asset asset = Asset(assetAddress);
        asset.transferTo(target, amount * 1 ether);
    }

    function supplyFor(string memory ticker) public view returns (uint256) {
        address assetAddress = assets[ticker];
        if (assetAddress == address(0)) { revert AssetNotFound(); }

        Asset asset = Asset(assetAddress);
        return asset.supply();
    }

    function balanceFor(string memory ticker) public view returns(uint256) {
        address assetAddress = assets[ticker];
        if (assetAddress == address(0)) { revert AssetNotFound(); }

        Asset asset = Asset(assetAddress);
        return asset.balanceOf(msg.sender);
    }
}