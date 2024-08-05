// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.6 <0.9.0;

contract Upload {
    // It is used to that the account have access or not
    struct Access {
        address user;
        bool access; //true of false
    }

    //This dynamic array is used to store the url of images on smart contract that are uploaded on IPFS using selected account.
    mapping(address => string[]) value;

    //This nested mapping is used to store whether a account have access to main account's images or not.
    mapping(address => mapping(address => bool)) ownership;

    //This Access array is used to store the addresses of the accounts that may or may not have access of the images of selected account
    // and this array is mapped with the selected account address.
    mapping(address => Access[]) accessList;

    //This nested mapping is used to store the previous state of our data
    mapping(address => mapping(address => bool)) previousData;

    //this function is used to push url of the image in the value array and it is mapped with account that uploaded this image
    function add(address _user, string memory url) external {
        value[_user].push(url);
    }

    //It allows the main user to give access to other user's accounts
    function allow(address user) external {
        ownership[msg.sender][user] = true;

        if (previousData[msg.sender][user]) {
            for (uint i = 0; i < accessList[msg.sender].length; i++) {
                if (accessList[msg.sender][i].user == user) {
                    accessList[msg.sender][i].access = true;
                }
            }
        } else {
            accessList[msg.sender].push(Access(user, true));
            previousData[msg.sender][user] = true;
        }
    }

    //this function allows main user to revoke access of the images from other user's accounts that currently have access
    function disallow(address user) public {
        ownership[msg.sender][user] = false;

        for (uint i = 0; i < accessList[msg.sender].length; i++) {
            if (accessList[msg.sender][i].user == user) {
                accessList[msg.sender][i].access = false;
            }
        }
    }

    //this function is used to display images on the screen
    function display(address _user) external view returns (string[] memory) {
        require(
            _user == msg.sender || ownership[_user][msg.sender],
            "You don't have access."
        );
        return value[_user];
    }

    //this function is used to fetch the list of addresses that curently have access of images
    function shareAccess() public view returns (Access[] memory) {
        return accessList[msg.sender];
    }
}
