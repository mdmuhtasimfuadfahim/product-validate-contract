// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ProductValidation {
    uint256 public currentIndustryId;
    uint256 public currentProductId;

    address payable trustedParty; // the trusted party who will add the industries

    /*╔═════════════════════════════╗
      ║          Structs            ║
      ╚═════════════════════════════╝*/
    struct product {
        uint256 foodId; //should be a uniqueID
        string productExpiurationDate; // given by farmer
        string nameOfOwner; // given by farmer
        uint256 productAmount;
        uint256 currentProductId; // will receive the value from uint256 public currentProductId for tracking
        address addedBy;
    }

    struct Industry {
        uint256 insdustryId; //should be a uniqueID
        string insdustryName;
        uint256 insdustryID; // will receive the value from uint256 public currentIndustryId for tracking
        address payable industryWalletAddress; // the wallet addresses who can call the storeProductInfo function

        // you can store more info if needed
    }

    Industry[] public industries; // array of industries
    mapping(uint256 => product) public productInfo;

    constructor(
        address payable _trustedParty,
        uint256 _currentIndustryId,
        uint256 _currentProductId
    ) {
        trustedParty = _trustedParty;
        currentIndustryId = _currentIndustryId;
        currentProductId = _currentProductId;
    }

    /*╔═════════════════════════════╗
      ║           EVENTS            ║
      ╚═════════════════════════════╝*/
    event productAdded(
        uint256 foodID,
        string productExpiurationDate,
        string nameOfOwner,
        uint256 productAmount,
        uint256 currentProductId,
        address addedBy
    );

    event industryAdded(
        uint256 insdustryId,
        string insdustryName,
        uint256 insdustryID,
        address payable industryWalletAddress
    );

    /*╔═════════════════════════════╗
      ║       Helper Function       ║
      ╚═════════════════════════════╝*/
    function _getTrustedParty(address _trustedParty)
        internal
        view
        returns (bool)
    {
        if (_trustedParty == trustedParty) return true;
        else return false;
    }

    /*
     * @function _isWalletAddress
     * @functiondesc - this will return true is the wallet given wallet address is valid otherwise it will return false
     * @requires _walletAddress
     */
    function _isWalletAddress(address _walletAddress)
        internal
        view
        returns (bool)
    {
        uint256 size;
        assembly {
            size := extcodesize(_walletAddress)
        }

        return size > 0;
    }

    /*╔═════════════════════════════╗
      ║         Modifiers           ║
      ╚═════════════════════════════╝*/
    modifier isTrustedParty() {
        require(
            trustedParty == msg.sender,
            "You are not the truest party. Better try next time :D"
        );
        _;
    }

    modifier isTrustedPartyWalletValid(address _trustedParty) {
        require(
            !_isWalletAddress(_trustedParty),
            "Trusted party wallet address is not valid"
        );
        _;
    }

    modifier isIndustryWalletValid(address _industryWalletAddress) {
        require(
            !_isWalletAddress(_industryWalletAddress),
            "Trusted party wallet address is not valid"
        );
        _;
    }

    /*╔══════════════════════════════╗
      ║       Create Industry        ║
      ╚══════════════════════════════╝*/

    /*****************************************************************
     *  create industry list who will be allowed to add product info  *
     *****************************************************************/
    function createIndustries(
        uint256 _insdustryId,
        string memory _insdustryName,
        address payable _trustedParty,
        address payable _industryWalletAddress
    )
        public
        payable
        // this trustedParty will be the one who deployed the contract
        isTrustedParty
        isTrustedPartyWalletValid(_trustedParty)
        isIndustryWalletValid(_industryWalletAddress)
    {
        if (
            // check if the truestParty wallet address and industryWalletAddress are not same
            _trustedParty != _industryWalletAddress
        ) {
            if (
                // check if the trusted party address is the msg.sender or not
                _getTrustedParty(_trustedParty)
            ) {
                currentIndustryId += 1;
                industries.push(
                    Industry({
                        insdustryId: _insdustryId,
                        insdustryName: _insdustryName,
                        insdustryID: currentIndustryId, // at first iteration currentIndustryId will be 1+
                        industryWalletAddress: _industryWalletAddress
                    })
                );

                // industryAdded event call to notify all nodes in the blockchain
                emit industryAdded(
                    _insdustryId,
                    _insdustryName,
                    currentIndustryId,
                    _industryWalletAddress
                );
            } else {
                revert("You are not allowed to add industries");
            }
        } else {
            revert(
                "Trusted party address and industries wallet address cannot be same"
            );
        }
    }

    /*╔══════════════════════════════╗
      ║        Store Product         ║
      ╚══════════════════════════════╝*/

    /***********************************************
     *  to store product information in blockchain  *
     **********************************************/
    function storeProductInfo(
        uint256 _foodId,
        string memory _productExpiurationDate,
        string memory _nameOfOwner,
        uint256 _productAmount,
        address payable _industryWalletAddress
    ) public payable isIndustryWalletValid(_industryWalletAddress) {
        // to check that the validated industry is calling this function or not
        for (uint256 i = 0; i < industries.length; i += 1) {
            if (
                // check if the wallet address match with the validated industries wallet address
                industries[i].industryWalletAddress == msg.sender &&
                industries[i].industryWalletAddress == _industryWalletAddress
            ) {
                currentProductId += 1;
                productInfo[_foodId].nameOfOwner = _nameOfOwner;
                productInfo[_foodId].foodId = _foodId;
                productInfo[_foodId].productAmount = _productAmount;
                productInfo[_foodId]
                    .productExpiurationDate = _productExpiurationDate;
                productInfo[_foodId].currentProductId = currentProductId;
                productInfo[_foodId].addedBy = msg.sender;

                emit productAdded(
                    _foodId,
                    _productExpiurationDate,
                    _nameOfOwner,
                    _productAmount,
                    currentProductId,
                    msg.sender
                );
            } else {
                // No Industry found with this ID and Name
                revert("You are not permitted to add product info");
            }
        }
    }
}
