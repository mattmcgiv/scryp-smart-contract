pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient {
    function receiveApproval (address _from, uint256 _value, address _token, bytes _extraData);
}

contract ScrypTestflight is owned {
    /* Public variables of the token */
    string public standard = "Test Scryp 0.1";
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ScrypTestflight(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address centralMinter
        ) {
            if (centralMinter != 0 ) {
                owner = centralMinter;
            }

            // Give the creator all initial tokens
            balanceOf[msg.sender] = initialSupply;
            // Update total supply
            totalSupply = initialSupply;
            // Set the name for display purposes
            name = tokenName;
            // Set the symbol for display purposes
            symbol = tokenSymbol;
            // Amount of decimals for display purposes
            decimals = decimalUnits;
        }

    /*This is a function allowing the owner to mint new tokens after contract deployment*/
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        // Prevent transfer to 0x0 address. Use burn() instead
        if (_to == 0x0) {
            throw;
        }
        // Check if the sender has enough
        if (balanceOf[msg.sender] < _value) {
            throw;
        }
        // Check for overflows
        if (balanceOf[_to] + _value < balanceOf[_to]) {
            throw;
        }
        // Subtract from the sender
        balanceOf[msg.sender] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        // Notify anyone listening that this transfer took place
        Transfer(msg.sender, _to, _value);
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        // Prevent transfer to 0x0 address. Use burn() instead
        if (_to == 0x0) {
            throw;
        }
        // Check if the sender has enough
        if (balanceOf[_from] < _value) {
            throw;
        }
        // Check for overflows
        if (balanceOf[_to] + _value < balanceOf[_to]) {
            throw;
        }
        // Check allowance
        if (_value > allowance[_from][msg.sender]) {
            throw;
        }
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) returns (bool success) {
        // Check if the sender has enough
        if (balanceOf[msg.sender] < _value) {
            throw;
        }
        // Subtract from the sender
        balanceOf[msg.sender] -= _value;
        // Updates totalSupply
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) returns (bool success) {
        // Check if the sender has enough
        if (balanceOf[_from] < _value) {
            throw;
        }
        // Check allowance
        if (_value > allowance[_from][msg.sender]) {
            throw;
        }
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Updates totalSupply
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}