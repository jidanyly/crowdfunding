pragma solidity ^0.5.0;

contract Crowfunding{

    struct Project{
        uint id;//(项目id)
        address user;//众筹发起人
        address payable to;//收款地址
        uint currentAmount;//当前筹集数量
        uint maxAmount;//最大筹集数量
        uint currentPeople;
        uint maxPeople;
        mapping(address => uint) fromDetail;
        address payable[] allFroms;
        uint status;

    }
    Project[] public projects;

    event NewProject(address from, address to, uint maxAmount, uint maxPeople);
    event NewContribution(address from, uint pid, uint amount);
    event CloseProject(uint pid);

    //添加项目 参数：收款地址，最大众筹数量，最大众筹人数
    function add(address payable _to, uint _maxAmount, uint _maxPeople) public returns(bool){
        require(_maxAmount > 0, "Amount must be greater than 0");
        require(_maxPeople > 0, "People must be greater than 0");
        projects.length++;
        Project storage p = projects[projects.length - 1];
        p.id = projects.length - 1;
        p.to = _to;
        p.user = msg.sender;
        p.maxAmount = _maxAmount;
        p.maxPeople = _maxPeople;
        p.status = 1;
        emit NewProject(msg.sender, _to, _maxAmount, _maxPeople);
        return ture;
    }

    //捐款
    function Contribution(uint _pid) public payable returns(bool){
        Project storage p = projects[_pid];
        require(msg.value > 0, "Amount must be greater than 0");
        require(p.status != 0, "Crowdfunding has stopped");
        require(p.currentPeople + 1 <= p.maxPeople, "Exceed the maximum number of people");

        if(p.fromDetail[msg.sender] == 0){
            p.currentPeople += 1;
            p.allFroms.push(msg.sender);
        }
        p.fromDetail[msg.sender] += msg.value;

        uint newAmount = p.currentAmount + msg.value;

        if(newAmount >= p.maxAmount){
            p.status = 2;
            p.to.transfer(newAmount);
        }else if(p.currentPeople == p.maxPeople){
            p.status = 0;
            closeProjectInernal(_pid);
        }
        p.currentAmount += msg.value;
        emit NewContribution(msg.sender, _pid, msg.value);
        return ture;
    }

    //关闭项目
    function closePrejectInternal(uint _pid) internal returns (bool){
        Project storage p = projects[_pid];
        require(p.user == msg.sender, "You don't have permission");
        require(p.status != 0, "Crowdfunding has stopped");
        closePrejectInternal(_pid);
        p.status = 0;
    }

    function closePrejectInternal(uint _pid) internal returns (bool){
        Project storage p = projects[_pid];
        mapping(address => uint) storage _fromDetail = p.fromDetail;
        address payable[] memory _allFroms = p.allFroms;
        for(uint i; i < allFroms.length; i++){
            address payable account = _allFroms[i];
            uint amount = _fromDetail[account];
            account.transfer(amount);
        }
        emit CloseProject(_pid);
    }

    //项目总长度
    function projectLength() punlic view returns(uint){
        return projects.length;
    }

}