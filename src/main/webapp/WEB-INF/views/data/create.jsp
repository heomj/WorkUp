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
	/* 레이아웃 위치 조정 */
    .container-fluid {
        padding-top: 5px !important; 
        padding-bottom: 10px !important;
        padding-left: 5px !important; 
        margin-bottom: 10px !important;
    }
    .header-main-row {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
    }
</style>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<div class="container-fluid">
    <div class="page-header" style="margin: 0; display: flex; justify-content: space-between; align-items: flex-end; padding-bottom: 15px;">
        
        <div class="d-flex flex-column">
            <div class="header-main-row" style="display: flex; align-items: center; gap: 8px; margin-bottom: 2px !important;">
                <span class="material-icons" style="font-size: 26px !important; color: #696cff !important; vertical-align: middle;">
                    forum
                </span>
                <span style="font-size: x-large; font-weight: 800; line-height: 1;">게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 자료실</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 자료실 등록</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc" style="font-size: 0.92rem; color: #6c757d; margin: 0 !important; padding: 0 !important; font-family: sans-serif; line-height: 1.2;">
                    업무에 필요한 서식 및 각종 자료를 공유하고 다운로드할 수 있는 페이지입니다.
                </p>
            </div>
        </div>
    </div>
</div>

    <div class="card border-0 shadow-sm" style="background-color: #ffffff !important;">
        <div class="card-body p-4 p-lg-5" style="background-color: #ffffff !important;">
            <form id="dataForm" onsubmit="return false;" enctype="multipart/form-data">
                <%-- Spring Security 사용 시 CSRF 토큰 필요 --%>
                <sec:csrfInput />
                
                <div class="row g-3">
                    <div class="col-md-3">
					    <label class="form-label">카테고리</label>
					    <select class="form-select" name="dataType">
					        <option value="1" selected>일반자료</option>
					        <option value="2">업무양식</option>
					        <option value="3">기술자료</option>
					        <option value="4">중요 (상단 고정)</option>
					    </select>
					</div>

                    <div class="col-12 mt-4">
					    <label for="dataTtl" class="form-label d-flex justify-content-between align-items-center">
					        <span>제목</span>
					        <span id="dataNmCount" class="text-muted small fw-normal">0 / 100</span>
					    </label>
					    <input type="text" class="form-control form-control-lg fw-bold" id="dataTtl" name="dataNm" 
					           placeholder="자료 제목을 입력하세요" maxlength="100" required>
					</div>
					
					<div class="col-12 mt-4">
					    <label class="form-label d-flex justify-content-between align-items-center">
					        <span>자료 상세 설명</span>
					        <span id="dataCnCount" class="text-muted small fw-normal">0 / 2000</span>
					    </label>
                        <div class="editor-container">
                            <textarea class="form-control border-0 shadow-none rounded-0 p-3" id="dataCn" name="dataCn" rows="15" placeholder="자료에 대한 설명을 상세히 작성해 주세요."></textarea>
                        </div>
                    </div>

                    <div class="col-12 mt-4">
                        <label class="form-label">파일 업로드</label>
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
                    <button type="button" class="btn btn-light border px-4" onclick="location.href='/data'">취소</button>
                    <button type="submit" class="btn btn-primary px-5 fw-bold">등록하기</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    const fileInput = document.getElementById('fileInput');
    const fileList = document.getElementById('fileList');
    const dropZone = document.getElementById('dropZone');

    // [전역 변수] 서버로 전송할 파일들을 관리하는 배열
    let selectedFiles = [];
    
 	// [추가] 페이지 로드 시 실시간 글자 수 설정
    document.addEventListener('DOMContentLoaded', function() {
        const dataNmInput = document.getElementById('dataTtl'); // create.jsp는 id가 dataTtl임
        const dataCnInput = document.getElementById('dataCn');

        // 실시간 입력 이벤트 등록
        dataNmInput.addEventListener('input', () => updateCount(dataNmInput, 'dataNmCount', 100));
        dataCnInput.addEventListener('input', () => updateCount(dataCnInput, 'dataCnCount', 2000));
    });

    // [추가] 글자 수 업데이트 함수 (update.jsp와 동일)
    function updateCount(input, countId, max) {
        const len = input.value.length;
        const countEl = document.getElementById(countId);
        if(!countEl) return;
        
        countEl.innerText = `\${len} / \${max}`;
        if (len >= max) {
            countEl.classList.replace('text-muted', 'text-danger');
            countEl.classList.add('fw-bold');
        } else {
            countEl.classList.replace('text-danger', 'text-muted');
            countEl.classList.remove('fw-bold');
        }
    }

    // 1. 클릭 시 파일 탐색기 열기
    dropZone.addEventListener('click', () => fileInput.click());

    // 2. 파일 선택 시 (탐색기 사용)
    fileInput.addEventListener('change', function() {
        // 기존 선택된 파일에 새로 선택한 파일들을 추가 (누적 방식)
        const newFiles = Array.from(this.files);
        syncFiles(newFiles);
    });
    

    // 3. 드래그 앤 드롭 기능
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

    // [파일 동기화 함수] 배열에 파일을 추가하고 input 태그와 동기화함
    function syncFiles(files) {
        // 신규 파일들을 기존 배열에 추가
        files.forEach(file => {
            // 중복 파일 체크 (파일명과 크기가 같으면 제외 - 선택 사항)
            const isDuplicate = selectedFiles.some(f => f.name === file.name && f.size === file.size);
            if (!isDuplicate) {
                selectedFiles.push(file);
            }
        });

        updateInputAndDisplay();
    }

    // [삭제 함수] 휴지통 버튼 클릭 시 호출
    function removeFile(index) {
        // 배열에서 해당 인덱스 삭제
        selectedFiles.splice(index, 1);
        updateInputAndDisplay();
    }

    // [핵심 로직] 배열의 상태를 input.files와 화면에 반영
    function updateInputAndDisplay() {
        // 1. DataTransfer를 사용하여 input[type=file]의 값을 강제 업데이트
        const dataTransfer = new DataTransfer();
        selectedFiles.forEach(file => {
            dataTransfer.items.add(file);
        });
        fileInput.files = dataTransfer.files;

        // 2. 화면 리스트 렌더링
        renderFileList();
    }

    // [화면 렌더링 함수]
    function renderFileList() {
        fileList.innerHTML = "";
        
        selectedFiles.forEach((file, index) => {
            const div = document.createElement('div');
            div.className = "file-item border p-2 mb-2 d-flex justify-content-between align-items-center";
            div.style.backgroundColor = "#fff";
            div.innerHTML = `
                <div class="d-flex align-items-center">
                    <span class="material-icons text-primary me-2" style="font-size:20px">description</span>
                    <span class="fw-medium text-dark">\${file.name}</span>
                    <span class="text-muted small ms-2">(\${(file.size / 1024 / 1024).toFixed(2)} MB)</span>
                </div>
                <button type="button" class="btn btn-outline-danger btn-sm p-1 border-0" onclick="removeFile(\${index})" title="삭제">
                    <span class="material-icons" style="font-size:20px">delete_outline</span>
                </button>
            `;
            fileList.appendChild(div);
        });
    }
    
 // 4. 등록하기 버튼 클릭 시 실행 (유효성 검사 강화 버전)
    document.querySelector('button[type="submit"]').addEventListener('click', function(e) {
        e.preventDefault();

        const dataNmInput = document.getElementById('dataTtl');
        const dataCnInput = document.getElementById('dataCn');
        const dataNm = dataNmInput.value;
        const dataCn = dataCnInput.value;

        // 1. 제목 검증 (수정 페이지와 동일한 철벽 방어)
        if (!dataNm.trim()) {
            Swal.fire('경고', '제목을 입력해주세요.', 'warning').then(() => dataNmInput.focus());
            return;
        }
        if (dataNm.length >= 100) {
            Swal.fire({
                icon: 'error',
                title: '등록 불가',
                text: '제목이 100자를 초과했습니다.',
                confirmButtonColor: '#ff3e1d'
            }).then(() => dataNmInput.focus());
            return; // Axios 실행 방지
        }

        // 2. 내용 검증
        if (!dataCn.trim()) {
            Swal.fire('경고', '내용을 입력해주세요.', 'warning').then(() => dataCnInput.focus());
            return;
        }
        if (dataCn.length >= 2000) {
            Swal.fire({
                icon: 'error',
                title: '등록 불가',
                text: '내용이 2000자를 초과했습니다.',
                confirmButtonColor: '#ff3e1d'
            }).then(() => dataCnInput.focus());
            return; // Axios 실행 방지
        }

        // --- 모든 검증 통과 시 전송 ---
        const form = document.getElementById('dataForm');
        const formData = new FormData(form);

        axios.post('/data/createAjax', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        })
        .then(res => {
            if(res.data.result === 'success') {
                Swal.fire('등록 완료', '자료가 성공적으로 등록되었습니다.', 'success')
                .then(() => location.href = '/data');
            } else {
                Swal.fire('실패', res.data.message || '등록 중 오류가 발생했습니다.', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            Swal.fire('에러', '서버와의 통신에 실패했습니다.', 'error');
        });
    });
</script>