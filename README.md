# DZBlockChain Smart Contract

## Giới thiệu

DZBlockChain là một smart contract được phát triển trên blockchain Ethereum, được thiết kế để quản lý hệ thống giáo dục phi tập trung. Contract này cung cấp một giải pháp toàn diện để quản lý bài thi, điểm số, yêu cầu phúc khảo, quản lý tests, hệ thống truy vết và phát hành chứng chỉ dưới dạng NFT (Non-Fungible Token).

## Tính năng chính

### 1. **Hệ thống phân quyền (Access Control)**
- **ADMIN_ROLE**: Quản trị viên có quyền cao nhất
- **LECTURER_ROLE**: Giảng viên có thể tạo bài thi, chấm điểm
- **STUDENT_ROLE**: Sinh viên có thể xem điểm và yêu cầu phúc khảo
- **EMPLOYER_ROLE**: Nhà tuyển dụng có thể xác minh chứng chỉ

### 2. **Quản lý địa chỉ sinh viên**
- Liên kết ID sinh viên với địa chỉ Ethereum
- Đảm bảo mỗi sinh viên chỉ có một địa chỉ duy nhất

### 3. **Quản lý bài thi**
- Tạo và lưu trữ thông tin bài thi
- Khóa bài thi để ngăn chỉnh sửa
- Theo dõi lịch sử tạo bài thi

### 4. **Quản lý điểm số**
- Lưu trữ và cập nhật điểm số
- Hoàn thiện điểm số (finalize)
- Kiểm soát quyền truy cập xem điểm

### 5. **Hệ thống phúc khảo**
- Sinh viên có thể yêu cầu phúc khảo điểm
- Giảng viên xử lý yêu cầu phúc khảo
- Cập nhật điểm sau khi phúc khảo

### 6. **Quản lý Tests**
- Tạo và quản lý các bài test
- Chặn/bỏ chặn test
- Theo dõi người tạo và thời gian tạo

### 7. **Hệ thống truy vết (Trace System)**
- Ghi log tất cả hoạt động quan trọng
- Theo dõi lịch sử thay đổi
- Kiểm soát quyền truy cập log

### 8. **Quản lý bài làm sinh viên (Student Answer)**
- Sinh viên nộp bài làm với hash nội dung
- Giảng viên chấm điểm bài làm
- Theo dõi thời gian nộp bài và chấm điểm
- Truy xuất bài làm theo student_id và exam_id

### 9. **Chứng chỉ NFT**
- Phát hành chứng chỉ dưới dạng NFT
- Xác minh tính hợp lệ của chứng chỉ
- Thu hồi chứng chỉ khi cần thiết

## Cách sử dụng

### A. Quản lý quyền truy cập

#### 1. Cấp quyền giảng viên
```solidity
function grantLecturerRole(address account) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Chỉ admin mới có thể cấp quyền giảng viên cho một địa chỉ  
**Tham số**: `account` - Địa chỉ cần cấp quyền giảng viên  
**Quyền**: Chỉ ADMIN_ROLE

#### 2. Cấp quyền sinh viên
```solidity
function grantStudentRole(address account) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Cấp quyền sinh viên cho một địa chỉ  
**Tham số**: `account` - Địa chỉ cần cấp quyền sinh viên  
**Quyền**: Chỉ ADMIN_ROLE

#### 3. Cấp quyền nhà tuyển dụng
```solidity
function grantEmployerRole(address account) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Cấp quyền nhà tuyển dụng cho một địa chỉ  
**Tham số**: `account` - Địa chỉ cần cấp quyền nhà tuyển dụng  
**Quyền**: Chỉ ADMIN_ROLE

### B. Quản lý địa chỉ sinh viên

#### 1. Thiết lập địa chỉ sinh viên
```solidity
function setStudentAddress(uint256 _student_id, address _studentAddress) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Liên kết ID sinh viên với địa chỉ Ethereum  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_studentAddress`: Địa chỉ Ethereum của sinh viên  
**Quyền**: Chỉ ADMIN_ROLE

#### 2. Cập nhật địa chỉ sinh viên
```solidity
function updateStudentAddress(uint256 _student_id, address _newAddress) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Cập nhật địa chỉ mới cho sinh viên  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_newAddress`: Địa chỉ mới của sinh viên  
**Quyền**: Chỉ ADMIN_ROLE

#### 3. Lấy địa chỉ sinh viên
```solidity
function getStudentAddress(uint256 _student_id) public view returns (address)
```
**Mô tả**: Lấy địa chỉ Ethereum của sinh viên theo ID  
**Tham số**: `_student_id` - ID của sinh viên  
**Trả về**: Địa chỉ Ethereum của sinh viên

### C. Quản lý bài thi

#### 1. Tạo bài thi
```solidity
function storeExam(string memory _hash, uint256 _exam_id) public nonReentrant
```
**Mô tả**: Tạo và lưu trữ thông tin bài thi mới  
**Tham số**:
- `_hash`: Hash của đề thi
- `_exam_id`: ID duy nhất của bài thi  
**Quyền**: ADMIN_ROLE hoặc LECTURER_ROLE  
**Trả về**: Thông tin bài thi đã tạo

#### 2. Tạo bài thi với truy vết
```solidity
function storeExamWithTrace(string memory _hash, uint256 _exam_id) public nonReentrant
```
**Mô tả**: Tạo bài thi mới kèm ghi log truy vết  
**Tham số**:
- `_hash`: Hash của đề thi
- `_exam_id`: ID duy nhất của bài thi  
**Quyền**: ADMIN_ROLE hoặc LECTURER_ROLE  
**Tính năng**: Tự động ghi log vào hệ thống trace

#### 3. Khóa bài thi
```solidity
function lockExam(uint256 _exam_id) public
```
**Mô tả**: Khóa bài thi để ngăn chỉnh sửa  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: ADMIN_ROLE hoặc người tạo bài thi

#### 4. Xem thông tin bài thi
```solidity
function getExam(uint256 _exam_id) public view returns (...)
```
**Mô tả**: Lấy thông tin chi tiết của bài thi  
**Tham số**: `_exam_id` - ID của bài thi  
**Trả về**: Hash, ID, người tạo, thời gian tạo, trạng thái khóa và kích hoạt

### D. Quản lý Tests

#### 1. Tạo test
```solidity
function createTest(uint256 _test_id, uint256 _id_created_by) public onlyRole(ADMIN_ROLE) nonReentrant
```
**Mô tả**: Tạo test mới trong hệ thống  
**Tham số**:
- `_test_id`: ID duy nhất của test
- `_id_created_by`: ID người tạo test  
**Quyền**: Chỉ ADMIN_ROLE

#### 2. Chặn test
```solidity
function blockTest(uint256 _test_id) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Chặn test không cho sử dụng  
**Tham số**: `_test_id` - ID của test  
**Quyền**: Chỉ ADMIN_ROLE

#### 3. Bỏ chặn test
```solidity
function unblockTest(uint256 _test_id) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Bỏ chặn test đã bị chặn  
**Tham số**: `_test_id` - ID của test  
**Quyền**: Chỉ ADMIN_ROLE

#### 4. Xem thông tin test
```solidity
function getTest(uint256 _test_id) public view returns (...)
```
**Mô tả**: Lấy thông tin chi tiết của test  
**Tham số**: `_test_id` - ID của test  
**Trả về**: ID test, người tạo, thời gian tạo, trạng thái chặn, trạng thái kích hoạt

#### 5. Lấy danh sách test của user
```solidity
function getUserTests(uint256 _user_id) public view returns (uint256[] memory)
```
**Mô tả**: Lấy danh sách tất cả test do user tạo  
**Tham số**: `_user_id` - ID của user  
**Trả về**: Mảng các test ID

### E. Quản lý bài làm sinh viên (Student Answer)

#### 1. Nộp bài làm
```solidity
function submitAnswer(uint256 _student_id, uint256 _exam_id, string memory _content) public onlyRole(STUDENT_ROLE)
```
**Mô tả**: Sinh viên nộp bài làm cho một bài thi  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_content`: Hash của tất cả câu trả lời  
**Quyền**: Chỉ STUDENT_ROLE  
**Điều kiện**: Sinh viên chỉ có thể nộp bài cho chính mình, bài thi chưa bị khóa

#### 2. Nộp bài làm của tôi
```solidity
function submitMyAnswer(uint256 _exam_id, string memory _content) public onlyRole(STUDENT_ROLE)
```
**Mô tả**: Sinh viên nộp bài làm của mình (tự động lấy student_id từ địa chỉ)  
**Tham số**:
- `_exam_id`: ID của bài thi
- `_content`: Hash của tất cả câu trả lời  
**Quyền**: Chỉ STUDENT_ROLE

#### 3. Chấm điểm bài làm
```solidity
function scoreAnswer(uint256 _student_id, uint256 _exam_id, uint256 _score) public onlyRole(LECTURER_ROLE)
```
**Mô tả**: Giảng viên chấm điểm cho bài làm của sinh viên  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_score`: Điểm số (0-100)  
**Quyền**: Chỉ LECTURER_ROLE  
**Điều kiện**: Bài làm đã được nộp

#### 4. Cập nhật điểm bài làm
```solidity
function updateAnswerScore(uint256 _student_id, uint256 _exam_id, uint256 _new_score) public onlyRole(LECTURER_ROLE)
```
**Mô tả**: Cập nhật điểm số cho bài làm đã được chấm  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_new_score`: Điểm số mới (0-100)  
**Quyền**: Chỉ LECTURER_ROLE

#### 5. Xem bài làm của sinh viên
```solidity
function getStudentAnswer(uint256 _student_id, uint256 _exam_id) public view returns (StudentAnswer memory)
```
**Mô tả**: Xem thông tin bài làm của sinh viên  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi  
**Quyền**: LECTURER_ROLE, ADMIN_ROLE hoặc chính sinh viên đó  
**Trả về**: Thông tin chi tiết bài làm

#### 6. Xem bài làm của tôi
```solidity
function getMyAnswer(uint256 _exam_id) public view onlyRole(STUDENT_ROLE) returns (StudentAnswer memory)
```
**Mô tả**: Sinh viên xem bài làm của chính mình  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: Chỉ STUDENT_ROLE

#### 7. Lấy danh sách bài nộp của bài thi
```solidity
function getExamSubmissions(uint256 _exam_id) public view returns (uint256[] memory)
```
**Mô tả**: Lấy danh sách ID sinh viên đã nộp bài cho bài thi  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: LECTURER_ROLE hoặc ADMIN_ROLE  
**Trả về**: Mảng các student_id

#### 8. Kiểm tra đã nộp bài
```solidity
function hasSubmittedAnswer(uint256 _student_id, uint256 _exam_id) public view returns (bool)
```
**Mô tả**: Kiểm tra sinh viên đã nộp bài cho bài thi hay chưa  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi  
**Trả về**: true nếu đã nộp, false nếu chưa

#### 9. Lấy điểm bài làm
```solidity
function getAnswerScore(uint256 _student_id, uint256 _exam_id) public view returns (uint256)
```
**Mô tả**: Lấy điểm số của bài làm  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi  
**Quyền**: LECTURER_ROLE, ADMIN_ROLE hoặc chính sinh viên đó  
**Trả về**: Điểm số của bài làm

### F. Quản lý điểm số

#### 1. Lưu điểm số
```solidity
function storeScore(uint256 _student_id, uint256 _exam_id, uint256 _score) public onlyRole(LECTURER_ROLE) nonReentrant
```
**Mô tả**: Lưu điểm số cho sinh viên trong một bài thi  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_score`: Điểm số (0-100)  
**Quyền**: Chỉ LECTURER_ROLE

#### 2. Lưu điểm số với truy vết
```solidity
function storeScoreWithTrace(uint256 _student_id, uint256 _exam_id, uint256 _score) public onlyRole(LECTURER_ROLE) nonReentrant
```
**Mô tả**: Lưu điểm số kèm ghi log truy vết  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_score`: Điểm số (0-100)  
**Quyền**: Chỉ LECTURER_ROLE  
**Tính năng**: Tự động ghi log vào hệ thống trace

#### 3. Cập nhật điểm số
```solidity
function updateScore(uint256 _student_id, uint256 _exam_id, uint256 _new_score) public onlyRole(LECTURER_ROLE) nonReentrant
```
**Mô tả**: Cập nhật điểm số cho sinh viên (chỉ khi chưa hoàn thiện)  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_new_score`: Điểm số mới (0-100)  
**Quyền**: Chỉ LECTURER_ROLE

#### 4. Hoàn thiện điểm số
```solidity
function finalizeScore(uint256 _student_id, uint256 _exam_id) public onlyRole(LECTURER_ROLE)
```
**Mô tả**: Hoàn thiện điểm số, sau đó không thể chỉnh sửa  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi  
**Quyền**: Chỉ LECTURER_ROLE

#### 5. Xem điểm số của tôi
```solidity
function getMyScore(uint256 _exam_id) public view onlyRole(STUDENT_ROLE) returns (...)
```
**Mô tả**: Sinh viên xem điểm số của chính mình  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: Chỉ STUDENT_ROLE  
**Trả về**: Thông tin điểm số chi tiết

### G. Hệ thống phúc khảo

#### 1. Yêu cầu phúc khảo
```solidity
function createMyReviewRequest(uint256 _exam_id, string memory _reason) public onlyRole(STUDENT_ROLE) nonReentrant
```
**Mô tả**: Sinh viên tạo yêu cầu phúc khảo điểm của mình  
**Tham số**:
- `_exam_id`: ID của bài thi
- `_reason`: Lý do yêu cầu phúc khảo  
**Quyền**: Chỉ STUDENT_ROLE

#### 2. Xử lý yêu cầu phúc khảo
```solidity
function processReviewRequest(uint256 _student_id, uint256 _exam_id, string memory _review_status, uint256 _new_score) public onlyRole(LECTURER_ROLE) nonReentrant
```
**Mô tả**: Giảng viên xử lý yêu cầu phúc khảo  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_review_status`: Trạng thái ("APPROVED" hoặc "REJECTED")
- `_new_score`: Điểm số mới (nếu được phê duyệt)  
**Quyền**: Chỉ LECTURER_ROLE

#### 3. Xem yêu cầu phúc khảo của tôi
```solidity
function getMyReviewRequest(uint256 _exam_id) public view onlyRole(STUDENT_ROLE) returns (...)
```
**Mô tả**: Sinh viên xem yêu cầu phúc khảo của mình  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: Chỉ STUDENT_ROLE

### H. Hệ thống truy vết (Trace System)

#### 1. Xem lịch sử truy vết
```solidity
function getTraces(uint256 _entity_id) public view returns (TraceRecord[] memory)
```
**Mô tả**: Xem tất cả bản ghi truy vết của một entity  
**Tham số**: `_entity_id` - ID của entity cần truy vết  
**Quyền**: ADMIN_ROLE hoặc LECTURER_ROLE  
**Trả về**: Mảng các bản ghi TraceRecord

#### 2. Đếm số bản ghi truy vết
```solidity
function getTraceCount(uint256 _entity_id) public view returns (uint256)
```
**Mô tả**: Đếm số lượng bản ghi truy vết của entity  
**Tham số**: `_entity_id` - ID của entity  
**Trả về**: Số lượng bản ghi

**Cấu trúc TraceRecord:**
```solidity
struct TraceRecord {
    uint256 timestamp;    // Thời gian thực hiện
    address caller;       // Địa chỉ người thực hiện
    string action;        // Hành động được thực hiện
    uint256 target_id;    // ID đối tượng bị tác động
    string details;       // Chi tiết bổ sung
}
```

### I. Quản lý chứng chỉ NFT

#### 1. Phát hành chứng chỉ
```solidity
function issueCertificate(uint256 _student_id, uint256 _exam_id, string memory _metadata_uri) public nonReentrant returns (uint256)
```
**Mô tả**: Phát hành chứng chỉ NFT cho sinh viên  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi
- `_metadata_uri`: URI chứa metadata của chứng chỉ  
**Quyền**: ADMIN_ROLE hoặc LECTURER_ROLE  
**Trả về**: Token ID của chứng chỉ NFT

#### 2. Thu hồi chứng chỉ
```solidity
function revokeCertificate(uint256 _tokenId) public onlyRole(ADMIN_ROLE)
```
**Mô tả**: Thu hồi chứng chỉ (đánh dấu không hợp lệ)  
**Tham số**: `_tokenId` - Token ID của chứng chỉ  
**Quyền**: Chỉ ADMIN_ROLE

#### 3. Xác minh chứng chỉ
```solidity
function verifyCertificate(uint256 _tokenId) public view onlyRole(EMPLOYER_ROLE) returns (Certificate memory)
```
**Mô tả**: Nhà tuyển dụng xác minh tính hợp lệ của chứng chỉ  
**Tham số**: `_tokenId` - Token ID của chứng chỉ  
**Quyền**: Chỉ EMPLOYER_ROLE  
**Trả về**: Thông tin chi tiết của chứng chỉ

#### 4. Xem chứng chỉ của tôi
```solidity
function getMyCertificate(uint256 _student_id, uint256 _exam_id) public view onlyRole(STUDENT_ROLE) returns (Certificate memory)
```
**Mô tả**: Sinh viên xem chứng chỉ của mình  
**Tham số**:
- `_student_id`: ID của sinh viên
- `_exam_id`: ID của bài thi  
**Quyền**: Chỉ STUDENT_ROLE

### J. Các hàm hỗ trợ

#### 1. Lấy danh sách bài thi của giảng viên
```solidity
function getLecturerExams(address _lecturer) public view returns (uint256[] memory)
```
**Mô tả**: Lấy danh sách các bài thi do giảng viên tạo  
**Tham số**: `_lecturer` - Địa chỉ của giảng viên

#### 2. Lấy danh sách điểm số của bài thi
```solidity
function getExamScores(uint256 _exam_id) public view returns (uint256[] memory)
```
**Mô tả**: Lấy danh sách ID sinh viên có điểm trong bài thi  
**Tham số**: `_exam_id` - ID của bài thi  
**Quyền**: ADMIN_ROLE hoặc LECTURER_ROLE

## Cấu trúc dữ liệu chính

### 1. Tests
```solidity
struct Tests {
    uint256 test_id;       // ID duy nhất của test
    uint256 id_created_by; // ID người tạo test
    uint256 created_at;    // Thời gian tạo (timestamp)
    bool is_blocked;       // Trạng thái chặn
    bool is_active;        // Trạng thái kích hoạt
}
```

### 2. TraceRecord
```solidity
struct TraceRecord {
    uint256 timestamp;     // Thời gian thực hiện
    address caller;        // Địa chỉ người thực hiện
    string action;         // Hành động được thực hiện
    uint256 target_id;     // ID đối tượng bị tác động
    string details;        // Chi tiết bổ sung
}
```

### 3. Exam
```solidity
struct Exam {
    string hash;           // Hash của đề thi
    uint256 exam_id;       // ID duy nhất của bài thi
    address created_by;    // Người tạo
    uint256 created_at;    // Thời gian tạo
    bool is_locked;        // Đã khóa hay chưa
    bool is_active;        // Còn hoạt động hay không
}
```

### 4. StudentAnswer
```solidity
struct StudentAnswer {
    uint256 student_id;    // ID sinh viên
    uint256 exam_id;       // ID bài thi
    string content;        // Hash của tất cả câu trả lời
    uint256 score;         // Điểm sau khi chấm (default = 0)
    uint256 submitted_at;  // Thời gian nộp bài
    address submitted_by;  // Địa chỉ nộp bài
    uint256 scored_at;     // Thời gian chấm điểm
    address scored_by;     // Giảng viên chấm điểm
    bool is_submitted;     // Đã nộp bài chưa
    bool is_scored;        // Đã chấm điểm chưa
}
```

### 5. Score
```solidity
struct Score {
    uint256 student_id;    // ID sinh viên
    uint256 exam_id;       // ID bài thi
    uint256 score;         // Điểm số (0-100)
    address graded_by;     // Người chấm
    uint256 created_at;    // Thời gian tạo
    uint256 updated_at;    // Thời gian cập nhật
    bool is_final;         // Đã finalize chưa
}
```

### 6. Certificate
```solidity
struct Certificate {
    uint256 tokenId;       // ID NFT
    uint256 student_id;    // ID sinh viên
    uint256 exam_id;       // ID bài thi
    uint256 score;         // Điểm số
    string metadata_uri;   // URI metadata
    uint256 issued_at;     // Thời gian phát hành
    address issued_by;     // Người phát hành
    bool is_valid;         // Còn hiệu lực
}
```

## Sự kiện (Events)

Contract phát ra các sự kiện quan trọng để theo dõi hoạt động:

### Quản lý quyền
- `RoleGranted`: Khi cấp quyền
- `RoleRevoked`: Khi thu hồi quyền

### Quản lý bài thi
- `ExamStored`: Khi tạo bài thi mới
- `ExamLocked`: Khi khóa bài thi

### Quản lý Tests
- `TestCreated`: Khi tạo test mới
- `TestBlocked`: Khi chặn test
- `TestUnblocked`: Khi bỏ chặn test

### Quản lý bài làm sinh viên
- `AnswerSubmitted`: Khi sinh viên nộp bài làm
- `AnswerScored`: Khi giảng viên chấm điểm bài làm
- `AnswerUpdated`: Khi cập nhật điểm bài làm

### Quản lý điểm số
- `ScoreStored`: Khi lưu điểm số
- `ScoreUpdated`: Khi cập nhật điểm số
- `ScoreFinalized`: Khi hoàn thiện điểm số

### Hệ thống phúc khảo
- `ReviewRequested`: Khi yêu cầu phúc khảo
- `ReviewProcessed`: Khi xử lý phúc khảo

### Hệ thống truy vết
- `TraceRecorded`: Khi ghi bản ghi truy vết

### Quản lý chứng chỉ
- `CertificateIssued`: Khi phát hành chứng chỉ
- `CertificateRevoked`: Khi thu hồi chứng chỉ

### Quản lý sinh viên
- `StudentAddressSet`: Khi thiết lập địa chỉ sinh viên
- `StudentAddressUpdated`: Khi cập nhật địa chỉ sinh viên

## Bảo mật

Contract được trang bị các tính năng bảo mật:

1. **Reentrancy Guard**: Ngăn chặn tấn công reentrancy
2. **Access Control**: Kiểm soát quyền truy cập nghiêm ngặt
3. **Input Validation**: Xác thực tất cả dữ liệu đầu vào
4. **State Management**: Quản lý trạng thái an toàn
5. **Trace Logging**: Ghi log tất cả hoạt động quan trọng
6. **Role-based Permissions**: Phân quyền chi tiết cho từng chức năng

## Quy trình hoạt động

### 1. Khởi tạo hệ thống
1. Deploy contract (người deploy tự động có ADMIN_ROLE)
2. Admin cấp quyền cho giảng viên, sinh viên, nhà tuyển dụng
3. Admin thiết lập địa chỉ cho sinh viên

### 2. Quản lý bài thi và tests
1. Admin tạo tests trong hệ thống
2. Giảng viên tạo bài thi (có thể dùng storeExamWithTrace để ghi log)
3. Admin có thể chặn/bỏ chặn tests khi cần

### 3. Nộp bài và chấm điểm
1. Sinh viên nộp bài làm (submitMyAnswer) với hash nội dung
2. Giảng viên chấm điểm bài làm (scoreAnswer)
3. Giảng viên có thể tạo Score từ StudentAnswer (createScoreFromAnswer)
4. Sinh viên xem điểm và yêu cầu phúc khảo nếu cần
5. Giảng viên xử lý phúc khảo
6. Giảng viên finalize điểm

### 4. Phát hành chứng chỉ
1. Giảng viên/Admin phát hành chứng chỉ NFT
2. Sinh viên nhận chứng chỉ NFT vào wallet
3. Nhà tuyển dụng có thể xác minh chứng chỉ

### 5. Truy vết và audit
1. Admin/Giảng viên có thể xem lịch sử truy vết
2. Tất cả hoạt động quan trọng được ghi log tự động
3. Hệ thống đảm bảo tính minh bạch và có thể audit

## Yêu cầu hệ thống

- Solidity ^0.8.6
- Mạng tương thích với EVM (Ethereum, Polygon, BSC, etc.)
- Gas limit đủ cho các transaction phức tạp

## Lưu ý quan trọng

1. Chỉ admin mới có thể cấp và thu hồi quyền
2. Điểm số sau khi hoàn thiện không thể chỉnh sửa trực tiếp
3. Mỗi sinh viên chỉ có thể có một địa chỉ Ethereum duy nhất
4. Chứng chỉ NFT có thể được chuyển nhượng theo chuẩn ERC-721
5. Tất cả các thao tác quan trọng đều được ghi log thông qua events
6. Hệ thống truy vết giúp theo dõi và audit mọi hoạt động
7. Tests có thể bị chặn bởi admin khi cần thiết
8. Sử dụng functions có trace để có log chi tiết hơn

## Kết luận

DZBlockChain cung cấp một giải pháp blockchain hoàn chỉnh cho hệ thống giáo dục, đảm bảo tính minh bạch, bảo mật và không thể thay đổi của dữ liệu giáo dục. Với việc bổ sung hệ thống quản lý tests và trace logging, contract này có thể được sử dụng để xây dựng các ứng dụng quản lý giáo dục phi tập trung với độ tin cậy cao và khả năng audit hoàn chỉnh. 