pragma solidity ^0.4.0;

contract Bank {
    address BankManager;
    uint256 NoOfUsers=0;
    uint256 MinBalance;
    uint256 DepositLimit;
    uint256 WithdrawLimit;
    uint256 TransferLimit;
    
     function Bank()  { 
        BankManager=msg.sender;
    }
    
    struct Account {
        uint256 UserNo;
        bool SecondUser;
        address SecondUserAddress;
        string[] UserName;
        uint256[] FixedDeposit;
        uint256 balance;
        bool FirstUserActive;
        bool SecondUserActive;
        bool AccountExists;
    }
    
    mapping (address => Account) Users;
    address[]  UserList;
    
}


contract UserAccountManage is Bank {
    function UserAccountManage(uint256 w, uint256 x, uint256 y, uint256 z)  { 
        MinBalance=w;
        DepositLimit=x;
        WithdrawLimit=y;
        TransferLimit=z;
    }
    
    /* Bank functions 
       WhichUser=1 is for the first user 
       WhichUser=2 is for the second user
    */
    
    function AddUser(address _add1, address _add2, string s1, string s2, uint256 x){
        if (msg.sender!=BankManager){
            revert();
        }
        if (x >= MinBalance){    
            var user=Users[_add1];
            user.balance=x;
            user.UserName.push(s1);
            user.FirstUserActive=true;
            user.AccountExists=true;
            UserList.push(_add1)-1;
            if (_add2!=0x0){
                user.SecondUser=true;
                user.SecondUserAddress=_add2;
                user.UserName.push(s2);
                user.SecondUserActive=true;
            }
            else{
                user.SecondUser=false;
            }
            NoOfUsers=NoOfUsers+1;
            user.UserNo=NoOfUsers;
        }
        else{
            revert();
        }
    }
    
    function DeleteUser(uint256 WhichUser) returns (bool){
        address temp=GetUser(WhichUser);
        if (WhichUser==1){
            Users[temp].FirstUserActive=false;
        }
        else{
            Users[temp].SecondUserActive=false;
        }
        if(Users[temp].FirstUserActive==false && Users[temp].SecondUserActive==false){
            uint256 i;
            for (i=0; i<UserList.length;i++){
                if (temp == UserList[i]){
                    break;
                }
            }
            UserList=Remove(i);
            NoOfUsers=NoOfUsers-1;
            return true;
        }
        else{
            return false;
        }

    }

    function CheckMinBalance(address index) view returns (bool){
        if (Users[index].balance < MinBalance){
            return false;
        }
        return true;
    }
    
    function Deposit(uint256 val, uint256 WhichUser) returns (bool){
        if (val > DepositLimit){
            return false;
        }
        address index=GetUser(WhichUser);
        if (IsUserActive(index,WhichUser)){
            Users[index].balance+=val;
            return true;
        }
        else{
            return false;
        }
    }
    
    function Withdraw(uint256 val, uint256 WhichUser) returns (bool) {
        address index=GetUser(WhichUser);
        if (IsUserActive(index, WhichUser)==false && val > TransferLimit){
            return false;
        }
        if (Users[index].balance >= val && val <= WithdrawLimit){
            Users[index].balance-=val;
        }
        else{
            return false;
        }
        if (CheckMinBalance(index)){
            return true;
        }
        else{
            Users[index].balance+=val;
            return false;
        }
    }
    
    function Transfer(uint256 val, uint256 WhichUser, address To) returns (bool){
        address index=GetUser(WhichUser);
        if (IsUserActive(index, WhichUser)==false){
            return false;
        }
        if (Users[To].AccountExists && Users[index].balance>=val){
            Users[index].balance-=val;
            if (CheckMinBalance(index)){
                Users[To].balance+=val;
                return true;
            }
            else{
                Users[index].balance+=val;
                return false;
            }
        }
    }
    
    function AddFixedDeposit (uint256 WhichUser, uint256 val) returns (bool){
        address index=GetUser(WhichUser);
        if (IsUserActive(index, WhichUser)==false){
            return false;
        }
        Users[index].FixedDeposit.push(val);
    }
    
    /* Account information */
    
    function ListOfUsers() public returns (address[]){
        if (msg.sender==BankManager){
            return UserList;
        }
    }
    
    function DisplayAccountBalance(uint256 WhichUser) public returns(uint256){
        address index=GetUser(WhichUser);
        if (IsUserActive(index, WhichUser)==false){
            return;
        }
        return Users[index].balance;
    }
    
    function DisplayFixedDeposits(uint256 WhichUser) public returns(uint256[]){
        address index=GetUser(WhichUser);
        if (IsUserActive(index, WhichUser)==false){
            return;
        }
        return Users[index].FixedDeposit;
    }
    
    /* helper functions */
    
    //function to get Account information from second user address
    function GetAccount(address data) returns (address){
        for (uint256 i=0; i<NoOfUsers; i++){
            if (data == Users[UserList[i]].SecondUserAddress){
                return UserList[i];
                break;
            }
        }
        return 0x0;
    }
    
    //function for first user confirmation
    function FirstUserConfirmation(address i) view returns (bool){
        if (msg.sender == i){
            return true;
        }
        else{
            return false;
        }
    }
    
    //function for second user confirmation
    function SecondUserConfirmation(address i) view returns (bool){
        if (msg.sender == Users[i].SecondUserAddress || Users[i].SecondUserAddress == 0x0){
            return true;
        }
        else{
            return false;
        }
    }
    
    //fuction to rescale array
    function Remove(uint index)  returns(address[]) {
        if (index >= UserList.length) return;

        for (uint i = index; i<UserList.length-1; i++){
            UserList[i] = UserList[i+1];
        }
        delete UserList[UserList.length-1];
        UserList.length--;
        return UserList;
    }
    
    //function to generate right User
    function GetUser(uint256 i) returns (address){
        address index;
        if (i==1){
            index=msg.sender;    
        }
        else{
            index=GetAccount(msg.sender);
        }
        return index;
    }

    //function to see if the user is active
    function IsUserActive(address i, uint256 x) returns (bool){
        if (x == 1){
            if (Users[i].FirstUserActive == true){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            if (Users[i].SecondUserActive == true){
                return true;
            }
            else{
                return false;
            }
        }
    }    
}

