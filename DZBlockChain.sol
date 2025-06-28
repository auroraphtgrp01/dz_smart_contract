// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// ========== INTERFACE DEFINITIONS ==========
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract DZBlockChain {
    // ========== ACCESS CONTROL ==========
    mapping(bytes32 => mapping(address => bool)) private _roles;
    mapping(bytes32 => bytes32) private _roleAdmins;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant LECTURER_ROLE = keccak256("LECTURER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant EMPLOYER_ROLE = keccak256("EMPLOYER_ROLE");

    // ========== REENTRANCY GUARD ==========
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    // ========== NFT STATE ==========
    string private _name = "DZBlockChain Certificate";
    string private _symbol = "DZBC";
    uint256 private _currentTokenId = 0;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // ========== BUSINESS LOGIC ==========
    struct Exam {
        string hash;
        uint256 exam_id;
        address created_by;
        uint256 created_at;
        bool is_locked;
        bool is_active;
    }

    struct Score {
        uint256 student_id;
        uint256 exam_id;
        uint256 score;
        address graded_by;
        uint256 created_at;
        uint256 updated_at;
        bool is_final;
    }

    struct ReviewRequest {
        uint256 student_id;
        uint256 exam_id;
        uint256 request_date;
        string status;
        uint256 old_score;
        uint256 new_score;
        string reason;
        address reviewer;
        uint256 reviewed_at;
        bool is_processed;
    }

    struct Certificate {
        uint256 tokenId;
        uint256 student_id;
        uint256 exam_id;
        uint256 score;
        string metadata_uri;
        uint256 issued_at;
        address issued_by;
        bool is_valid;
    }

    // Mappings
    mapping(uint256 => Exam) public exams;
    mapping(uint256 => mapping(uint256 => Score)) public scores;
    mapping(uint256 => mapping(uint256 => ReviewRequest)) public reviewRequests;
    mapping(uint256 => Certificate) public certificates;
    mapping(uint256 => mapping(uint256 => uint256)) public studentCertificates;

    // Additional mappings for tracking
    mapping(address => uint256[]) public lecturerExams;
    mapping(uint256 => uint256[]) public examScores;

    // Student address management
    mapping(uint256 => address) public studentAddresses;
    mapping(address => uint256) public addressToStudentId;

    // Events
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event ExamLocked(uint256 indexed exam_id, address indexed locked_by);
    event ScoreStored(
        uint256 indexed student_id,
        uint256 indexed exam_id,
        uint256 score,
        address indexed graded_by
    );
    event ScoreUpdated(
        uint256 indexed student_id,
        uint256 indexed exam_id,
        uint256 old_score,
        uint256 new_score,
        address indexed updated_by
    );
    event ScoreFinalized(
        uint256 indexed student_id,
        uint256 indexed exam_id,
        address indexed finalized_by
    );
    event ReviewRequested(
        uint256 indexed student_id,
        uint256 indexed exam_id,
        string status,
        uint256 old_score,
        string reason
    );
    event ReviewProcessed(
        uint256 indexed student_id,
        uint256 indexed exam_id,
        string status,
        uint256 new_score,
        address indexed reviewer
    );
    event CertificateIssued(
        uint256 indexed tokenId,
        uint256 indexed student_id,
        uint256 indexed exam_id,
        address issued_by
    );
    event CertificateRevoked(
        uint256 indexed tokenId,
        address indexed revoked_by
    );

    // Student address management events
    event StudentAddressSet(
        uint256 indexed student_id,
        address indexed studentAddress,
        address setBy
    );
    event StudentAddressUpdated(
        uint256 indexed student_id,
        address indexed oldAddress,
        address indexed newAddress,
        address updatedBy
    );

    // NFT Events
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    constructor() {
        _status = _NOT_ENTERED;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(LECTURER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(STUDENT_ROLE, ADMIN_ROLE);
        _setRoleAdmin(EMPLOYER_ROLE, ADMIN_ROLE);
    }

    // ========== ACCESS CONTROL IMPLEMENTATION ==========
    modifier onlyRole(bytes32 role) {
        require(
            hasRole(role, msg.sender),
            "Access denied"
        );
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role][account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        _roleAdmins[role] = adminRole;
    }

    function grantRole(
        bytes32 role,
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(role, account);
    }

    function revokeRole(
        bytes32 role,
        address account
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(role, account);
    }

    // ========== ROLE MANAGEMENT FUNCTIONS ==========

    function grantLecturerRole(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(LECTURER_ROLE, account);
    }

    function grantStudentRole(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(STUDENT_ROLE, account);
    }

    function grantEmployerRole(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(EMPLOYER_ROLE, account);
    }

    function revokeLecturerRole(address account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(LECTURER_ROLE, account);
    }

    function revokeStudentRole(address account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(STUDENT_ROLE, account);
    }

    function revokeEmployerRole(address account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(EMPLOYER_ROLE, account);
    }

    // ========== STUDENT ADDRESS MANAGEMENT ==========

    function setStudentAddress(
        uint256 _student_id,
        address _studentAddress
    ) public onlyRole(ADMIN_ROLE) {
        require(_student_id > 0, "Invalid student ID");
        require(_studentAddress != address(0), "Invalid address");
        require(
            studentAddresses[_student_id] == address(0),
            "Student address already set"
        );
        require(
            addressToStudentId[_studentAddress] == 0,
            "Address already linked to another student"
        );

        studentAddresses[_student_id] = _studentAddress;
        addressToStudentId[_studentAddress] = _student_id;

        emit StudentAddressSet(_student_id, _studentAddress, msg.sender);
    }

    function updateStudentAddress(
        uint256 _student_id,
        address _newAddress
    ) public onlyRole(ADMIN_ROLE) {
        require(_student_id > 0, "Invalid student ID");
        require(_newAddress != address(0), "Invalid address");
        require(
            studentAddresses[_student_id] != address(0),
            "Student address not set"
        );
        require(
            addressToStudentId[_newAddress] == 0,
            "Address already linked to another student"
        );

        address oldAddress = studentAddresses[_student_id];

        // Clear old mapping
        delete addressToStudentId[oldAddress];

        // Set new mapping
        studentAddresses[_student_id] = _newAddress;
        addressToStudentId[_newAddress] = _student_id;

        emit StudentAddressUpdated(
            _student_id,
            oldAddress,
            _newAddress,
            msg.sender
        );
    }

    function getStudentAddress(
        uint256 _student_id
    ) public view returns (address) {
        return studentAddresses[_student_id];
    }

    function getStudentIdByAddress(
        address _address
    ) public view returns (uint256) {
        return addressToStudentId[_address];
    }

    // ========== EXAM MANAGEMENT FUNCTIONS ==========

    event ExamStored(
        uint256 indexed exam_id,
        string hash,
        address indexed created_by,
        uint256 created_at,
        bytes32 indexed blockHash,
        uint256 blockNumber
    );

    function storeExam(
        string memory _hash,
        uint256 _exam_id
    )
        public
        nonReentrant
        returns (
            string memory hash,
            uint256 exam_id,
            address created_by,
            uint256 created_at,
            bool is_active
        )
    {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Caller must be admin or lecturer"
        );
        require(_exam_id > 0, "Invalid exam ID");
        require(bytes(_hash).length > 0, "Hash cannot be empty");
        require(!exams[_exam_id].is_active, "Exam already exists");

        exams[_exam_id] = Exam({
            hash: _hash,
            exam_id: _exam_id,
            created_by: msg.sender,
            created_at: block.timestamp,
            is_locked: false,
            is_active: true
        });

        lecturerExams[msg.sender].push(_exam_id);

        emit ExamStored(
            _exam_id,
            _hash,
            msg.sender,
            block.timestamp,
            blockhash(block.number - 1),
            block.number
        );

        return (_hash, _exam_id, msg.sender, block.timestamp, true);
    }

    function lockExam(uint256 _exam_id) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Caller must be admin or lecturer"
        );
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            exams[_exam_id].created_by == msg.sender ||
                hasRole(ADMIN_ROLE, msg.sender),
            "Only exam creator or admin can lock"
        );

        exams[_exam_id].is_locked = true;
        emit ExamLocked(_exam_id, msg.sender);
    }

    // ========== SCORE MANAGEMENT FUNCTIONS ==========

    function storeScore(
        uint256 _student_id,
        uint256 _exam_id,
        uint256 _score
    ) public onlyRole(LECTURER_ROLE) nonReentrant {
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            _score >= 0 && _score <= 100,
            "Score must be between 0 and 100"
        );
        require(_student_id > 0, "Invalid student ID");
        require(
            scores[_student_id][_exam_id].student_id == 0,
            "Score already exists"
        );

        scores[_student_id][_exam_id] = Score({
            student_id: _student_id,
            exam_id: _exam_id,
            score: _score,
            graded_by: msg.sender,
            created_at: block.timestamp,
            updated_at: block.timestamp,
            is_final: false
        });

        examScores[_exam_id].push(_student_id);
        emit ScoreStored(_student_id, _exam_id, _score, msg.sender);
    }

    function updateScore(
        uint256 _student_id,
        uint256 _exam_id,
        uint256 _new_score
    ) public onlyRole(LECTURER_ROLE) nonReentrant {
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            _new_score >= 0 && _new_score <= 100,
            "Score must be between 0 and 100"
        );
        require(
            scores[_student_id][_exam_id].student_id != 0,
            "Score does not exist"
        );
        require(!scores[_student_id][_exam_id].is_final, "Score is finalized");

        uint256 old_score = scores[_student_id][_exam_id].score;
        scores[_student_id][_exam_id].score = _new_score;
        scores[_student_id][_exam_id].updated_at = block.timestamp;

        emit ScoreUpdated(
            _student_id,
            _exam_id,
            old_score,
            _new_score,
            msg.sender
        );
    }

    function finalizeScore(
        uint256 _student_id,
        uint256 _exam_id
    ) public onlyRole(LECTURER_ROLE) {
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            scores[_student_id][_exam_id].student_id != 0,
            "Score does not exist"
        );
        require(
            !scores[_student_id][_exam_id].is_final,
            "Score already finalized"
        );

        scores[_student_id][_exam_id].is_final = true;
        emit ScoreFinalized(_student_id, _exam_id, msg.sender);
    }

    // ========== REVIEW REQUEST FUNCTIONS ==========

    function storeReviewRequest(
        uint256 _student_id,
        uint256 _exam_id,
        string memory _reason
    ) public onlyRole(STUDENT_ROLE) nonReentrant {
        require(
            studentAddresses[_student_id] == msg.sender,
            "Access denied: Can only request review for yourself"
        );
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            scores[_student_id][_exam_id].student_id != 0,
            "Score does not exist"
        );
        require(
            !reviewRequests[_student_id][_exam_id].is_processed,
            "Review already processed"
        );
        require(bytes(_reason).length > 0, "Reason cannot be empty");

        uint256 current_score = scores[_student_id][_exam_id].score;

        reviewRequests[_student_id][_exam_id] = ReviewRequest({
            student_id: _student_id,
            exam_id: _exam_id,
            request_date: block.timestamp,
            status: "PENDING",
            old_score: current_score,
            new_score: 0,
            reason: _reason,
            reviewer: address(0),
            reviewed_at: 0,
            is_processed: false
        });

        emit ReviewRequested(
            _student_id,
            _exam_id,
            "PENDING",
            current_score,
            _reason
        );
    }

    function createMyReviewRequest(
        uint256 _exam_id,
        string memory _reason
    ) public onlyRole(STUDENT_ROLE) nonReentrant {
        uint256 studentId = addressToStudentId[msg.sender];
        require(studentId > 0, "Student ID not found for this address");

        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            scores[studentId][_exam_id].student_id != 0,
            "Score does not exist"
        );
        require(
            !reviewRequests[studentId][_exam_id].is_processed,
            "Review already processed"
        );
        require(bytes(_reason).length > 0, "Reason cannot be empty");

        uint256 current_score = scores[studentId][_exam_id].score;

        reviewRequests[studentId][_exam_id] = ReviewRequest({
            student_id: studentId,
            exam_id: _exam_id,
            request_date: block.timestamp,
            status: "PENDING",
            old_score: current_score,
            new_score: 0,
            reason: _reason,
            reviewer: address(0),
            reviewed_at: 0,
            is_processed: false
        });

        emit ReviewRequested(
            studentId,
            _exam_id,
            "PENDING",
            current_score,
            _reason
        );
    }

    function processReviewRequest(
        uint256 _student_id,
        uint256 _exam_id,
        string memory _review_status,
        uint256 _new_score
    ) public onlyRole(LECTURER_ROLE) nonReentrant {
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            reviewRequests[_student_id][_exam_id].student_id != 0,
            "Review request does not exist"
        );
        require(
            !reviewRequests[_student_id][_exam_id].is_processed,
            "Review already processed"
        );
        require(
            keccak256(abi.encodePacked(_review_status)) ==
                keccak256(abi.encodePacked("APPROVED")) ||
                keccak256(abi.encodePacked(_review_status)) ==
                keccak256(abi.encodePacked("REJECTED")),
            "Status must be APPROVED or REJECTED"
        );

        if (
            keccak256(abi.encodePacked(_review_status)) ==
            keccak256(abi.encodePacked("APPROVED"))
        ) {
            require(
                _new_score >= 0 && _new_score <= 100,
                "Score must be between 0 and 100"
            );
        }

        reviewRequests[_student_id][_exam_id].status = _review_status;
        reviewRequests[_student_id][_exam_id].new_score = _new_score;
        reviewRequests[_student_id][_exam_id].reviewer = msg.sender;
        reviewRequests[_student_id][_exam_id].reviewed_at = block.timestamp;
        reviewRequests[_student_id][_exam_id].is_processed = true;

        if (
            keccak256(abi.encodePacked(_review_status)) ==
            keccak256(abi.encodePacked("APPROVED"))
        ) {
            uint256 old_score = scores[_student_id][_exam_id].score;
            scores[_student_id][_exam_id].score = _new_score;
            scores[_student_id][_exam_id].updated_at = block.timestamp;
            emit ScoreUpdated(
                _student_id,
                _exam_id,
                old_score,
                _new_score,
                msg.sender
            );
        }

        emit ReviewProcessed(
            _student_id,
            _exam_id,
            _review_status,
            _new_score,
            msg.sender
        );
    }

    // ========== NFT IMPLEMENTATION ==========

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(
            owner != address(0),
            "Invalid token"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        return certificates[tokenId].metadata_uri;
    }

    // ========== ERC-721 TRANSFER FUNCTIONS ==========

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    // ========== INTERNAL ERC-721 FUNCTIONS ==========

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // ========== CERTIFICATE MANAGEMENT ==========

    function issueCertificate(
        uint256 _student_id,
        uint256 _exam_id,
        string memory _metadata_uri
    ) public nonReentrant returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Caller must be admin or lecturer"
        );
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            scores[_student_id][_exam_id].student_id != 0,
            "Score does not exist"
        );
        require(scores[_student_id][_exam_id].is_final, "Score not finalized");
        require(
            studentCertificates[_student_id][_exam_id] == 0,
            "Certificate already issued"
        );
        require(
            bytes(_metadata_uri).length > 0,
            "Metadata URI cannot be empty"
        );
        require(
            studentAddresses[_student_id] != address(0),
            "Student address not set"
        );

        _currentTokenId++;
        uint256 tokenId = _currentTokenId;

        address studentAddress = studentAddresses[_student_id];
        _mint(studentAddress, tokenId);

        certificates[tokenId] = Certificate({
            tokenId: tokenId,
            student_id: _student_id,
            exam_id: _exam_id,
            score: scores[_student_id][_exam_id].score,
            metadata_uri: _metadata_uri,
            issued_at: block.timestamp,
            issued_by: msg.sender,
            is_valid: true
        });

        studentCertificates[_student_id][_exam_id] = tokenId;

        emit CertificateIssued(tokenId, _student_id, _exam_id, msg.sender);
        return tokenId;
    }

    function revokeCertificate(uint256 _tokenId) public onlyRole(ADMIN_ROLE) {
        require(
            certificates[_tokenId].tokenId != 0,
            "Certificate does not exist"
        );
        require(certificates[_tokenId].is_valid, "Certificate already revoked");

        certificates[_tokenId].is_valid = false;
        emit CertificateRevoked(_tokenId, msg.sender);
    }

    // ========== VIEW FUNCTIONS ==========

    function getExam(
        uint256 _exam_id
    )
        public
        view
        returns (
            string memory hash,
            uint256 exam_id,
            address created_by,
            uint256 created_at,
            bool is_locked,
            bool is_active
        )
    {
        Exam memory examData = exams[_exam_id];
        return (
            examData.hash,
            examData.exam_id,
            examData.created_by,
            examData.created_at,
            examData.is_locked,
            examData.is_active
        );
    }

    function getScore(
        uint256 _student_id,
        uint256 _exam_id
    )
        public
        view
        returns (
            uint256 student_id,
            uint256 exam_id,
            uint256 score,
            address graded_by,
            uint256 created_at,
            uint256 updated_at,
            bool is_final
        )
    {
        require(
            hasRole(LECTURER_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender) ||
                (studentAddresses[_student_id] == msg.sender &&
                    hasRole(STUDENT_ROLE, msg.sender)),
            "Access denied: Only lecturer, admin, or the student can view score"
        );

        Score memory scoreData = scores[_student_id][_exam_id];
        return (
            scoreData.student_id,
            scoreData.exam_id,
            scoreData.score,
            scoreData.graded_by,
            scoreData.created_at,
            scoreData.updated_at,
            scoreData.is_final
        );
    }

    function getReviewRequest(
        uint256 _student_id,
        uint256 _exam_id
    )
        public
        view
        returns (
            uint256 student_id,
            uint256 exam_id,
            uint256 request_date,
            string memory status,
            uint256 old_score,
            uint256 new_score,
            string memory reason,
            address reviewer,
            uint256 reviewed_at,
            bool is_processed
        )
    {
        require(
            hasRole(LECTURER_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender) ||
                (studentAddresses[_student_id] == msg.sender &&
                    hasRole(STUDENT_ROLE, msg.sender)),
            "Access denied: Only lecturer, admin, or the student can view review request"
        );

        ReviewRequest memory reviewData = reviewRequests[_student_id][_exam_id];
        return (
            reviewData.student_id,
            reviewData.exam_id,
            reviewData.request_date,
            reviewData.status,
            reviewData.old_score,
            reviewData.new_score,
            reviewData.reason,
            reviewData.reviewer,
            reviewData.reviewed_at,
            reviewData.is_processed
        );
    }

    // Student helper functions
    function getMyCertificate(
        uint256 _student_id,
        uint256 _exam_id
    ) public view onlyRole(STUDENT_ROLE) returns (Certificate memory) {
        require(
            studentAddresses[_student_id] == msg.sender,
            "Access denied: Not your certificate"
        );
        uint256 tokenId = studentCertificates[_student_id][_exam_id];
        require(tokenId != 0, "Certificate not found");
        return certificates[tokenId];
    }

    function getMyScore(
        uint256 _exam_id
    )
        public
        view
        onlyRole(STUDENT_ROLE)
        returns (
            uint256 student_id,
            uint256 exam_id,
            uint256 score,
            address graded_by,
            uint256 created_at,
            uint256 updated_at,
            bool is_final
        )
    {
        uint256 studentId = addressToStudentId[msg.sender];
        require(studentId > 0, "Student ID not found for this address");

        Score memory scoreData = scores[studentId][_exam_id];
        require(scoreData.student_id != 0, "Score not found");

        return (
            scoreData.student_id,
            scoreData.exam_id,
            scoreData.score,
            scoreData.graded_by,
            scoreData.created_at,
            scoreData.updated_at,
            scoreData.is_final
        );
    }

    function getMyReviewRequest(
        uint256 _exam_id
    )
        public
        view
        onlyRole(STUDENT_ROLE)
        returns (
            uint256 student_id,
            uint256 exam_id,
            uint256 request_date,
            string memory status,
            uint256 old_score,
            uint256 new_score,
            string memory reason,
            address reviewer,
            uint256 reviewed_at,
            bool is_processed
        )
    {
        uint256 studentId = addressToStudentId[msg.sender];
        require(studentId > 0, "Student ID not found for this address");

        ReviewRequest memory reviewData = reviewRequests[studentId][_exam_id];
        require(reviewData.student_id != 0, "Review request not found");

        return (
            reviewData.student_id,
            reviewData.exam_id,
            reviewData.request_date,
            reviewData.status,
            reviewData.old_score,
            reviewData.new_score,
            reviewData.reason,
            reviewData.reviewer,
            reviewData.reviewed_at,
            reviewData.is_processed
        );
    }

    function verifyCertificate(
        uint256 _tokenId
    ) public view onlyRole(EMPLOYER_ROLE) returns (Certificate memory) {
        require(
            certificates[_tokenId].tokenId != 0,
            "Certificate does not exist"
        );
        return certificates[_tokenId];
    }

    function getCertificateByStudent(
        uint256 _student_id,
        uint256 _exam_id
    ) public view onlyRole(EMPLOYER_ROLE) returns (Certificate memory) {
        uint256 tokenId = studentCertificates[_student_id][_exam_id];
        require(tokenId != 0, "Certificate not found");
        return certificates[tokenId];
    }

    function getLecturerExams(
        address _lecturer
    ) public view returns (uint256[] memory) {
        require(
            hasRole(LECTURER_ROLE, _lecturer) || hasRole(ADMIN_ROLE, _lecturer),
            "Address is not a lecturer"
        );
        return lecturerExams[_lecturer];
    }

    function getExamScores(
        uint256 _exam_id
    ) public view returns (uint256[] memory) {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Caller must be admin or lecturer"
        );
        return examScores[_exam_id];
    }

    
    struct Tests {
        uint256 test_id;
        uint256 id_created_by;
        uint256 created_at;
        bool is_blocked;
        bool is_active;
    }

    mapping(uint256 => Tests) public tests;
    mapping(uint256 => uint256[]) public userTests; 
    
    event TestCreated(
        uint256 indexed test_id,
        uint256 indexed id_created_by,
        uint256 created_at
    );
    event TestBlocked(
        uint256 indexed test_id,
        address indexed blocked_by
    );
    event TestUnblocked(
        uint256 indexed test_id,
        address indexed unblocked_by
    );

    function createTest(
        uint256 _test_id,
        uint256 _id_created_by
    ) public onlyRole(ADMIN_ROLE) nonReentrant {
        require(_test_id > 0, "Invalid test ID");
        require(_id_created_by > 0, "Invalid creator ID");
        require(!tests[_test_id].is_active, "Test already exists");

        tests[_test_id] = Tests({
            test_id: _test_id,
            id_created_by: _id_created_by,
            created_at: block.timestamp,
            is_blocked: false,
            is_active: true
        });

        userTests[_id_created_by].push(_test_id);

        emit TestCreated(_test_id, _id_created_by, block.timestamp);
    }

    function blockTest(uint256 _test_id) public onlyRole(ADMIN_ROLE) {
        require(tests[_test_id].is_active, "Test does not exist");
        require(!tests[_test_id].is_blocked, "Test already blocked");

        tests[_test_id].is_blocked = true;
        emit TestBlocked(_test_id, msg.sender);
    }

    function unblockTest(uint256 _test_id) public onlyRole(ADMIN_ROLE) {
        require(tests[_test_id].is_active, "Test does not exist");
        require(tests[_test_id].is_blocked, "Test is not blocked");

        tests[_test_id].is_blocked = false;
        emit TestUnblocked(_test_id, msg.sender);
    }

    function getTest(
        uint256 _test_id
    )
        public
        view
        returns (
            uint256 test_id,
            uint256 id_created_by,
            uint256 created_at,
            bool is_blocked,
            bool is_active
        )
    {
        Tests memory testData = tests[_test_id];
        require(testData.is_active, "Test does not exist");
        
        return (
            testData.test_id,
            testData.id_created_by,
            testData.created_at,
            testData.is_blocked,
            testData.is_active
        );
    }

    function getUserTests(
        uint256 _user_id
    ) public view returns (uint256[] memory) {
        return userTests[_user_id];
    }

    struct TraceRecord {
        uint256 timestamp;
        address caller;
        string action;
        uint256 target_id;
        string details;
    }

    mapping(uint256 => TraceRecord[]) public traces; 
    uint256 private _traceCounter = 0;

    event TraceRecorded(
        uint256 indexed entity_id,
        address indexed caller,
        string action,
        uint256 target_id,
        string details,
        uint256 timestamp
    );

    function addTrace(
        uint256 _entity_id,
        string memory _action,
        uint256 _target_id,
        string memory _details
    ) internal {
        traces[_entity_id].push(TraceRecord({
            timestamp: block.timestamp,
            caller: msg.sender,
            action: _action,
            target_id: _target_id,
            details: _details
        }));

        emit TraceRecorded(
            _entity_id,
            msg.sender,
            _action,
            _target_id,
            _details,
            block.timestamp
        );
    }

    function getTraces(
        uint256 _entity_id
    ) public view returns (TraceRecord[] memory) {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Access denied: Only admin or lecturer can view traces"
        );
        return traces[_entity_id];
    }

    function getTraceCount(
        uint256 _entity_id
    ) public view returns (uint256) {
        return traces[_entity_id].length;
    }

    function storeExamWithTrace(
        string memory _hash,
        uint256 _exam_id
    )
        public
        nonReentrant
        returns (
            string memory hash,
            uint256 exam_id,
            address created_by,
            uint256 created_at,
            bool is_active
        )
    {
        require(
            hasRole(ADMIN_ROLE, msg.sender) ||
                hasRole(LECTURER_ROLE, msg.sender),
            "Caller must be admin or lecturer"
        );
        require(_exam_id > 0, "Invalid exam ID");
        require(bytes(_hash).length > 0, "Hash cannot be empty");
        require(!exams[_exam_id].is_active, "Exam already exists");

        exams[_exam_id] = Exam({
            hash: _hash,
            exam_id: _exam_id,
            created_by: msg.sender,
            created_at: block.timestamp,
            is_locked: false,
            is_active: true
        });

        lecturerExams[msg.sender].push(_exam_id);

        addTrace(_exam_id, "EXAM_CREATED", _exam_id, string(abi.encodePacked("Hash: ", _hash)));

        emit ExamStored(
            _exam_id,
            _hash,
            msg.sender,
            block.timestamp,
            blockhash(block.number - 1),
            block.number
        );

        return (_hash, _exam_id, msg.sender, block.timestamp, true);
    }

    function storeScoreWithTrace(
        uint256 _student_id,
        uint256 _exam_id,
        uint256 _score
    ) public onlyRole(LECTURER_ROLE) nonReentrant {
        require(exams[_exam_id].is_active, "Exam does not exist");
        require(
            _score >= 0 && _score <= 100,
            "Score must be between 0 and 100"
        );
        require(_student_id > 0, "Invalid student ID");
        require(
            scores[_student_id][_exam_id].student_id == 0,
            "Score already exists"
        );

        scores[_student_id][_exam_id] = Score({
            student_id: _student_id,
            exam_id: _exam_id,
            score: _score,
            graded_by: msg.sender,
            created_at: block.timestamp,
            updated_at: block.timestamp,
            is_final: false
        });

        examScores[_exam_id].push(_student_id);

        addTrace(_exam_id, "SCORE_STORED", _student_id, string(abi.encodePacked("Score: ", uint2str(_score))));

        emit ScoreStored(_student_id, _exam_id, _score, msg.sender);
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
