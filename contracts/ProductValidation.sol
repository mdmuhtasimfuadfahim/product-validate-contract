// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ProductValidation {
    uint256 public currentIndustryId;
    uint256 public currentProductId;

    address payable trustedParty; // the trusted party who will add the industry
    address[] public industryAddress; // industry address to track the address inserted by trusted party

    /*╔═════════════════════════════╗
      ║          Structs            ║
      ╚═════════════════════════════╝*/
    struct Product {
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

    mapping(address => Industry) public industry; // store structs of Industry in a mapping
    mapping(uint256 => Product) public productInfo; // store structs of product in a mapping

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
      ║      Helper Functions       ║
      ╚═════════════════════════════╝*/
    function _getTrustedParty(address _trustedParty)
        internal
        view
        returns (bool success)
    {
        require(
            _trustedParty == trustedParty,
            "You are not permitted to call this function :D"
        );
        if (_trustedParty == trustedParty) {
            return true;
        } else {
            return false;
        }
    }

    function _getIndustries(address _industryWalletAddress)
        internal
        view
        returns (bool success)
    {
        require(
            industry[_industryWalletAddress].industryWalletAddress ==
                _industryWalletAddress,
            "You are not permitted to call this function :D"
        );
        if (
            industry[_industryWalletAddress].industryWalletAddress ==
            _industryWalletAddress
        ) {
            return true;
        } else {
            return false;
        }
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
    function createindustry(
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
        returns (string memory)
    {
        // check if the truestParty wallet address and industryWalletAddress are not same
        require(
            _trustedParty != _industryWalletAddress,
            "Trusted party address and industry wallet address cannot be same"
        );

        // check if the trusted party address is the msg.sender or not
        require(
            _getTrustedParty(_trustedParty),
            "You are not allowed to add any industry"
        );

        // check if the industry is already exists in the list or not
        require(
            industry[_industryWalletAddress].industryWalletAddress !=
                _industryWalletAddress,
            "This industry is already exists in the list"
        );

        currentIndustryId += 1;
        industry[_industryWalletAddress].insdustryId = _insdustryId;
        industry[_industryWalletAddress].insdustryName = _insdustryName;
        industry[_industryWalletAddress].insdustryID = currentIndustryId;
        industry[_industryWalletAddress]
            .industryWalletAddress = _industryWalletAddress;
        industryAddress.push(_industryWalletAddress);

        // industryAdded event call to notify all nodes in the blockchain
        emit industryAdded(
            _insdustryId,
            _insdustryName,
            currentIndustryId,
            _industryWalletAddress
        );

        return "Industry successfully added in Blockchain. Cheers !!";
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
    )
        public
        payable
        isIndustryWalletValid(_industryWalletAddress)
        returns (string memory)
    {
        // to check that the validated industry is calling this function or not
        require(
            _getIndustries(msg.sender),
            "You don't have access to add product"
        );

        currentProductId += 1;
        productInfo[_foodId].nameOfOwner = _nameOfOwner;
        productInfo[_foodId].foodId = _foodId;
        productInfo[_foodId].productAmount = _productAmount;
        productInfo[_foodId].productExpiurationDate = _productExpiurationDate;
        productInfo[_foodId].currentProductId = currentProductId;
        productInfo[_foodId].addedBy = msg.sender;

        // productAdded event call to notify all nodes in the blockchain
        emit productAdded(
            _foodId,
            _productExpiurationDate,
            _nameOfOwner,
            _productAmount,
            currentProductId,
            msg.sender
        );

        return "Successfully added the product information in Blockchain. Cheers !!";
    }
}
