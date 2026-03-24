<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<style>
    .form-label { font-weight: 600; color: #566a7f; font-size: 0.875rem; }
    .editor-container { border: 1px solid #d9dee3; border-radius: 0.375rem; overflow: hidden; }
    .editor-toolbar { background-color: #f8f9fa; border-bottom: 1px solid #d9dee3; padding: 0.5rem; display: flex; gap: 0.5rem; }
    .editor-toolbar .btn-toolbar { padding: 4px; color: #566a7f; cursor: pointer; border-radius: 4px; }
    .editor-toolbar .btn-toolbar:hover { background-color: #e9ecef; }
    .file-upload-box { border: 2px dashed #d9dee3; border-radius: 0.5rem; padding: 2.5rem; text-align: center; background-color: #fcfcfd; cursor: pointer; transition: all 0.2s ease; }
    .file-upload-box:hover { border-color: #696cff; background-color: #f0f0ff; }
    
    /* 선택된 파일 목록 스타일 */
    #fileList { margin-top: 10px; }
    .file-item { display: flex; align-items: center; justify-content: space-between; padding: 8px 12px; background: #f8f9fa; border-radius: 6px; margin-bottom: 5px; font-size: 0.9rem; }
.container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
    }

    /* 🚩 [추가] 헤더 행 정렬 클래스 */
    .header-main-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px; /* data/list.jsp 설정과 통일 */
    }

    .header-desc {
        font-size: 0.92rem; 
        color: #6c757d; 
        margin: 0 !important; 
        padding: 0 !important; 
        font-family: sans-serif; 
        line-height: 1.2;
    }
</style>

<div class="container-fluid">
    <div class="page-header" style="margin: 0; display: flex; justify-content: space-between; align-items: flex-end; padding-bottom: 15px;">
        
        <div class="d-flex flex-column">
            <div class="header-main-row">
                <span class="material-icons" style="font-size: 26px !important; color: #696cff !important; vertical-align: middle;">
                    forum
                </span>
                <span style="font-size: x-large; font-weight: 800; line-height: 1;">게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 부서별 게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 게시판 등록</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc">
                    구성원들이 자유롭게 소통하고 의견을 나누는 커뮤니티 공간입니다.
                </p>
            </div>
        </div>
    </div>
    
    </div>

    <div class="card border-0 shadow-sm" style="background-color: #ffffff !important;">
        <div class="card-body p-4 p-lg-5" style="background-color: #ffffff !important;">
            <form id="boardForm" onsubmit="return false;" enctype="multipart/form-data">
                <%-- Spring Security CSRF 토큰 --%>
                <sec:csrfInput />
                
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">게시글 분류</label>
                        <select class="form-select" name="bbsType" id="bbsType">
					        <option value="부서공지" selected>📌 부서공지</option>
					        <option value="자유글">💬 자유글</option>
					        <option value="정보공유">💡 정보공유</option>
                        </select>
                        <div class="form-text mt-2 text-primary small" id="typeDesc">부서공지 선택 시 목록 상단에 강조되어 고정됩니다.</div>
                    </div>

                    <div class="col-12 mt-4">
					    <label for="bbsNm" class="form-label d-flex justify-content-between align-items-center">
					        <span>제목</span>
					        <span id="bbsNmCount" class="text-muted small fw-normal">0 / 100</span>
					    </label>
					    <input type="text" class="form-control form-control-lg fw-bold" id="bbsNm" name="bbsNm" 
					           placeholder="부서원들과 공유할 제목을 입력하세요" maxlength="100" required>
					</div>
					
					<div class="col-12 mt-4">
					    <label class="form-label d-flex justify-content-between align-items-center">
					        <span>게시글 내용</span>
					        <span id="bbsCnCount" class="text-muted small fw-normal">0 / 2000</span>
					    </label>
					    <div class="editor-container">
					        <textarea class="form-control border-0 shadow-none rounded-0 p-3" id="bbsCn" name="bbsCn" 
					                  rows="15" placeholder="공유할 내용을 자유롭게 작성하세요." maxlength="2000"></textarea>
					    </div>
					</div>

                    <div class="col-12 mt-4">
                        <label class="form-label">파일 첨부</label>
                        <div class="file-upload-box" id="dropZone">
                            <span class="material-icons text-muted mb-2" style="font-size: 3rem;">cloud_upload</span>
                            <p class="mb-1 fw-bold">클릭하거나 파일을 이 곳에 드래그하세요.</p>
                            <p class="text-muted small mb-0">파일당 최대 50MB까지 업로드 가능합니다.</p>
                            <input type="file" class="d-none" id="fileInput" name="uploadFile" multiple>
                        </div>
                        <div id="fileList"></div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 mt-5">
                    <button type="button" class="btn btn-light border px-4" onclick="history.back()">취소</button>
                    <button type="button" class="btn btn-primary px-5 fw-bold" id="btnSubmit">등록하기</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    const fileInput = document.getElementById('fileInput');
    const fileList = document.getElementById('fileList');
    const dropZone = document.getElementById('dropZone');

    let selectedFiles = [];

    // 1. 파일 선택 이벤트
    dropZone.addEventListener('click', () => fileInput.click());

    fileInput.addEventListener('change', function() {
    	const newFiles = Array.from(this.files);
        syncFiles(newFiles);
    });

    // 2. 드래그 앤 드롭
    dropZone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropZone.style.borderColor = "#696cff";
        dropZone.style.backgroundColor = "#f0f0ff";
    });

    dropZone.addEventListener('dragleave', () => {
        dropZone.style.borderColor = "#d9dee3";
        dropZone.style.backgroundColor = "#fcfcfd";
    });

    dropZone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropZone.style.borderColor = "#d9dee3";
        dropZone.style.backgroundColor = "#fcfcfd";
        
        const droppedFiles = Array.from(e.dataTransfer.files);
        syncFiles(droppedFiles);
    });

    function syncFiles(files) {
        files.forEach(file => {
            const isDuplicate = selectedFiles.some(f => f.name === file.name && f.size === file.size);
            if (!isDuplicate) selectedFiles.push(file);
        });
        updateInputAndDisplay();
    }

    function removeFile(index) {
        selectedFiles.splice(index, 1);
        updateInputAndDisplay();
    }

    function updateInputAndDisplay() {
        const dataTransfer = new DataTransfer();
        selectedFiles.forEach(file => dataTransfer.items.add(file));
        fileInput.files = dataTransfer.files;

        fileList.innerHTML = "";
        selectedFiles.forEach((file, index) => {
            const div = document.createElement('div');
            div.className = "file-item";
            div.innerHTML = `
                <div class="d-flex align-items-center">
                    <span class="material-icons text-primary me-2" style="font-size:20px">insert_drive_file</span>
                    <span class="fw-medium text-dark">\${file.name}</span>
                    <span class="text-muted small ms-2">(\${(file.size / 1024 / 1024).toFixed(2)} MB)</span>
                </div>
                <button type="button" class="btn btn-outline-danger btn-sm border-0" onclick="removeFile(\${index})">
                    <span class="material-icons" style="font-size:18px">close</span>
                </button>
            `;
            fileList.appendChild(div);
        });
    }

    // 🚩 [수정 및 추가된 부분] 분류 변경 설명 + 글자수 카운팅
    document.addEventListener('DOMContentLoaded', function() {
        // [A] 분류 변경 로직
        const bbsTypeSelect = document.querySelector('select[name="bbsType"]');
        const typeDesc = document.getElementById('typeDesc');

        if (bbsTypeSelect && typeDesc) {
            bbsTypeSelect.addEventListener('change', function() {
                const type = this.value;
                if (type === '부서공지') {
                    typeDesc.innerText = "부서공지 선택 시 목록 상단에 강조되어 고정됩니다.";
                    typeDesc.className = "form-text mt-2 text-primary small";
                } else if (type === '자유글') {
                    typeDesc.innerText = "부서원들과 자유로운 일상을 공유해보세요.";
                    typeDesc.className = "form-text mt-2 text-muted small";
                } else if (type === '정보공유') {
                    typeDesc.innerText = "업무에 도움이 되는 유용한 정보를 공유합니다.";
                    typeDesc.className = "form-text mt-2 text-info small";
                }
            });
        }

        // [B] 실시간 글자수 카운팅 로직 추가
        const bbsNmInput = document.getElementById('bbsNm');
        const bbsCnInput = document.getElementById('bbsCn');
        const nmCount = document.getElementById('bbsNmCount');
        const cnCount = document.getElementById('bbsCnCount');

        if(bbsNmInput && nmCount) {
            bbsNmInput.addEventListener('input', function() {
                const len = this.value.length;
                nmCount.innerText = `\${len} / 100`;
                if (len >= 100) nmCount.classList.replace('text-muted', 'text-danger');
                else nmCount.classList.replace('text-danger', 'text-muted');
            });
        }

        if(bbsCnInput && cnCount) {
            bbsCnInput.addEventListener('input', function() {
                const len = this.value.length;
                cnCount.innerText = `\${len} / 2000`;
                if (len >= 2000) cnCount.classList.replace('text-muted', 'text-danger');
                else cnCount.classList.replace('text-danger', 'text-muted');
            });
        }
    });

 	// 3. 등록 처리 (강력한 글자수 검증 및 전송 차단)
    document.getElementById('btnSubmit').addEventListener('click', function(e) {
        e.preventDefault(); 
        
        const bbsNmInput = document.getElementById('bbsNm');
        const bbsCnInput = document.getElementById('bbsCn');
        
        // 공백 제거 후 값 가져오기
        const bbsNm = bbsNmInput.value;
        const bbsCn = bbsCnInput.value;

        // [디버깅] 제목이 몇 자로 인식되는지 콘솔에 출력 (F12에서 확인 가능)
        console.log("검증 시작 - 제목 길이:", bbsNm.length);

     	// [1] 제목 검증
        if(!bbsNm.trim()) {
            Swal.fire('경고', '제목을 입력해주세요.', 'warning').then(() => bbsNmInput.focus());
            return false;
        }
        
        // 🚩 100자 '이상'인 경우(100자 포함) 무조건 차단하고 싶다면 >= 100
        // 만약 100자까지는 허용하고 싶다면 기존처럼 > 100을 유지하되 
        // DB 용량(Byte) 문제가 발생하지 않는지 확인해야 합니다.
        if(bbsNm.length >= 100) { 
            console.error("차단됨: 제목이 100자 이상임");
            Swal.fire({
                icon: 'error',
                title: '제목 글자수 초과',
                text: '제목은 100자 미만으로 작성해주세요. (현재: ' + bbsNm.length + '자)',
                confirmButtonColor: '#696cff'
            }).then(() => bbsNmInput.focus());
            return false; 
        }

        // [2] 내용 검증 (내용도 2000자 '이상'이면 차단)
        if(!bbsCn.trim()) {
            Swal.fire('경고', '내용을 입력해주세요.', 'warning').then(() => bbsCnInput.focus());
            return false;
        }
        
        if(bbsCn.length >= 2000) {
            Swal.fire({
                icon: 'error',
                title: '내용 글자수 초과',
                text: '내용은 2000자 미만으로 작성해주세요. (현재: ' + bbsCn.length + '자)',
                confirmButtonColor: '#696cff'
            }).then(() => bbsCnInput.focus());
            return false;
        }

        // --- 모든 검증 통과 후 전송 ---
        const formData = new FormData(document.getElementById('boardForm'));

        axios.post('/board/createAjax', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        })
        .then(res => {
            const result = res.data.result;
            const message = res.data.message;

            if(result === 'success') {
                Swal.fire({
                    icon: 'success',
                    title: '등록 성공',
                    text: '게시글이 성공적으로 등록되었습니다.',
                    confirmButtonColor: '#696cff'
                }).then(() => location.href = '/board');
            } else {
                // 서버 측 검증 메시지 출력 (Controller에서 담아준 메시지)
                let displayMsg = message || '등록 중 오류가 발생했습니다.';
                Swal.fire({
                    icon: 'error',
                    title: '등록 불가',
                    text: displayMsg,
                    confirmButtonColor: '#ff3e1d'
                });
            }
        })
        .catch(err => {
            console.error("통신 에러:", err);
            Swal.fire('에러', '서버 통신 중 문제가 발생했습니다.', 'error');
        });
    });
</script>