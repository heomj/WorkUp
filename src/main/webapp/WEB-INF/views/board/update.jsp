<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<style>
    :root {
        --bs-body-bg-rgb: 245, 247, 250;
        --bs-card-border-radius: 0.625rem;
        --bs-card-box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        --primary-color: #696cff;
        --danger-color: #ff3e1d;
        --success-color: #71dd37;
    }

    /* 카드 및 레이아웃 */
    .card { border: none; border-radius: var(--bs-card-border-radius); box-shadow: var(--bs-card-box-shadow); background-color: #ffffff !important; }
    .form-label { font-weight: 600; color: #566a7f; font-size: 0.875rem; margin-bottom: 0.5rem; }
    
    /* 에디터 디자인 */
    .editor-container { border: 1px solid #d9dee3; border-radius: 0.375rem; overflow: hidden; }
    .editor-toolbar { background-color: #f8f9fa; border-bottom: 1px solid #d9dee3; padding: 0.6rem; display: flex; gap: 1rem; }
    .editor-toolbar .material-icons { font-size: 1.25rem; color: #566a7f; cursor: pointer; transition: color 0.2s; }
    .editor-toolbar .material-icons:hover { color: var(--primary-color); }

    /* 첨부파일 관리 섹션 */
    .attachment-section { background-color: #fcfcfd; border: 1px dashed #d9dee3; border-radius: 8px; padding: 1.5rem; }
    
    /* 파일 태그 공통 */
    .file-tag { 
        display: inline-flex; align-items: center; background: #ffffff; border: 1px solid #d9dee3; 
        padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; margin-right: 8px; margin-bottom: 8px; 
        color: #566a7f; transition: all 0.2s; box-shadow: 0 2px 4px rgba(0,0,0,0.02);
    }

    .tag-old { border-left: 4px solid var(--primary-color); }
    .tag-new { border-left: 4px solid var(--success-color); color: var(--success-color); font-weight: 500; }

    .file-tag .del-icon { color: var(--danger-color); margin-left: 8px; font-size: 1.2rem; cursor: pointer; opacity: 0.6; transition: 0.2s; }
    .file-tag .del-icon:hover { opacity: 1; transform: scale(1.1); }

    .btn-primary { background-color: var(--primary-color); border-color: var(--primary-color); }
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

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<div class="container-fluid">
    <div class="page-header" style="margin: 0; display: flex; justify-content: space-between; align-items: flex-end; padding-bottom: 15px;">
        
        <div class="d-flex flex-column">
            <div class="header-main-row">
                <span class="material-icons" style="font-size: 26px !important; color: #696cff !important; vertical-align: middle;">
                    forum
                </span>
                <span style="font-size: x-large; font-weight: 800; line-height: 1;">게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 부서별 게시판</span>
                <span style="color: #6c757d; font-weight: normal; line-height: 1;"> | 게시판 수정</span>
            </div>
            
            <div class="header-sub-content">
                <p class="header-desc">
                    구성원들이 자유롭게 소통하고 의견을 나누는 커뮤니티 공간입니다.
                </p>
            </div>
        </div>
    </div>
    
    </div>

    <div class="card shadow-sm">
        <div class="card-body p-4 p-lg-5">
            <form id="updateForm" onsubmit="return false;" enctype="multipart/form-data">
                <sec:csrfInput />
                <input type="hidden" name="bbsNo" value="${boardVO.bbsNo}">
                <input type="hidden" name="empId" value="${boardVO.empId}">
                
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">게시글 분류</label>
                        <select class="form-select" name="bbsType" id="bbsType">
                            <option value="부서공지" ${boardVO.bbsType == '부서공지' ? 'selected' : ''}>📌 부서공지</option>
                            <option value="자유글" ${boardVO.bbsType == '자유글' ? 'selected' : ''}>💬 자유글</option>
                            <option value="정보공유" ${boardVO.bbsType == '정보공유' ? 'selected' : ''}>💡 정보공유</option>
                        </select>
                        <div class="form-text mt-2 text-primary small" id="typeDesc">부서공지 선택 시 목록 상단에 강조되어 고정됩니다.</div>
                    </div>

                    <div class="col-12 mt-4">
                        <label for="bbsNm" class="form-label d-flex justify-content-between align-items-center">
                            <span>제목</span>
                            <span id="bbsNmCount" class="text-muted small fw-normal">0 / 100</span>
                        </label>
                        <input type="text" class="form-control form-control-lg fw-bold" name="bbsNm" id="bbsNm" 
                               value="${boardVO.bbsNm}" placeholder="제목을 입력하세요" maxlength="100" required>
                    </div>

                    <div class="col-12 mt-4">
                        <label class="form-label d-flex justify-content-between align-items-center">
                            <span>내용</span>
                            <span id="bbsCnCount" class="text-muted small fw-normal">0 / 2000</span>
                        </label>
                        <div class="editor-container">
                            <textarea class="form-control border-0 shadow-none rounded-0 p-3" name="bbsCn" id="bbsCn" 
                                      rows="12" style="font-size: 0.95rem; line-height: 1.6;" maxlength="2000">${boardVO.bbsCn}</textarea>
                        </div>
                    </div>

                    <div class="col-12 mt-4">
                        <label class="form-label">첨부파일 관리</label>
                        <div class="attachment-section">
                            <div class="mb-4" id="oldFileList">
                                <p class="small text-muted mb-3 fw-bold"><i class="material-icons align-middle" style="font-size:16px">history</i> 기존 업로드된 파일</p>
                                <div class="d-flex flex-wrap">
                                    <c:forEach var="fileDtl" items="${boardVO.fileTbVO.fileDetailVOList}">
                                        <span class="file-tag tag-old" id="oldFile_${fileDtl.fileDtlId}">
                                            <i class="material-icons me-1" style="font-size:16px">description</i>
                                            ${fileDtl.fileDtlONm} 
                                            <span class="material-icons del-icon" onclick="fn_deleteOldFile('${fileDtl.fileDtlId}')">cancel</span>
                                        </span>
                                    </c:forEach>
                                </div>
                                <div id="deleteFileInputs"></div>
                            </div>

                            <hr class="my-4" style="border-top: 1px dashed #d9dee3;">

                            <div class="new-file-upload">
                                <p class="small text-muted mb-3 fw-bold"><i class="material-icons align-middle" style="font-size:16px">add_circle_outline</i> 신규 파일 추가</p>
                                <input type="file" class="form-control mb-3" id="fileInput" name="uploadFiles" multiple style="max-width: 450px;">
                                <div id="newFileList" class="d-flex flex-wrap"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 mt-5">
                    <button type="button" class="btn btn-light border px-4" onclick="history.back()">취소</button>
                    <button type="button" class="btn btn-primary px-5 fw-bold" onclick="fn_submit()">수정 완료</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    let newSelectedFiles = [];
    const fileInput = document.getElementById('fileInput');
    const newFileListDiv = document.getElementById('newFileList');

    // [페이지 로드 시 초기화]
    document.addEventListener('DOMContentLoaded', function() {
        const bbsNmInput = document.getElementById('bbsNm');
        const bbsCnInput = document.getElementById('bbsCn');
        const bbsTypeSelect = document.getElementById('bbsType');

        // 1. 초기 글자 수 세팅
        updateCount(bbsNmInput, 'bbsNmCount', 100);
        updateCount(bbsCnInput, 'bbsCnCount', 2000);

        // 2. 실시간 글자 수 이벤트 등록
        bbsNmInput.addEventListener('input', () => updateCount(bbsNmInput, 'bbsNmCount', 100));
        bbsCnInput.addEventListener('input', () => updateCount(bbsCnInput, 'bbsCnCount', 2000));

        // 3. 분류 변경 설명 로직
        bbsTypeSelect.addEventListener('change', function() {
            const typeDesc = document.getElementById('typeDesc');
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
        // 초기 로드 시 설명 문구 한 번 더 적용
        bbsTypeSelect.dispatchEvent(new Event('change'));
    });

    function updateCount(input, countId, max) {
        const len = input.value.length;
        const countEl = document.getElementById(countId);
        countEl.innerText = `\${len} / \${max}`;
        if (len >= max) countEl.classList.replace('text-muted', 'text-danger');
        else countEl.classList.replace('text-danger', 'text-muted');
    }

    // [기존 파일 삭제]
    function fn_deleteOldFile(fileDtlId) {
        Swal.fire({
            title: '파일 삭제',
            text: "수정 완료 시 해당 파일이 영구 삭제됩니다. 삭제하시겠습니까?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#ff3e1d',
            confirmButtonText: '삭제',
            cancelButtonText: '취소'
        }).then((result) => {
            if (result.isConfirmed) {
                const target = document.getElementById('oldFile_' + fileDtlId);
                if(target) target.remove();
                
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'delFileDtlIds'; 
                input.value = fileDtlId;
                document.getElementById('deleteFileInputs').appendChild(input);
            }
        });
    }

    // [신규 파일 관리]
    fileInput.addEventListener('change', function() {
        const files = Array.from(this.files);
        files.forEach(file => {
            const isDuplicate = newSelectedFiles.some(f => f.name === file.name && f.size === file.size);
            if (!isDuplicate) newSelectedFiles.push(file);
        });
        updateFileInput();
        renderNewFileList();
    });

    function removeNewFile(index) {
        newSelectedFiles.splice(index, 1);
        updateFileInput();
        renderNewFileList();
    }

    function updateFileInput() {
        const dataTransfer = new DataTransfer();
        newSelectedFiles.forEach(file => dataTransfer.items.add(file));
        fileInput.files = dataTransfer.files;
    }

    function renderNewFileList() {
        newFileListDiv.innerHTML = "";
        newSelectedFiles.forEach((file, index) => {
            const span = document.createElement('span');
            span.className = "file-tag tag-new";
            span.innerHTML = `
                <i class="material-icons me-1" style="font-size:16px">note_add</i>
                \${file.name} 
                <span class="material-icons del-icon" onclick="removeNewFile(\${index})">cancel</span>
            `;
            newFileListDiv.appendChild(span);
        });
    }

    // [수정 제출 - 강화된 검증 로직]
    function fn_submit() {
        const bbsNmInput = document.getElementById('bbsNm');
        const bbsCnInput = document.getElementById('bbsCn');
        const bbsNm = bbsNmInput.value;
        const bbsCn = bbsCnInput.value;

        // 1. 제목 검증
        if(!bbsNm.trim()) {
            Swal.fire('경고', '제목을 입력해주세요.', 'warning').then(() => bbsNmInput.focus());
            return;
        }
        if(bbsNm.length >= 100) {
            Swal.fire('경고', '제목이 100자를 초과했습니다.', 'error').then(() => bbsNmInput.focus());
            return;
        }

        // 2. 내용 검증
        if(!bbsCn.trim()) {
            Swal.fire('경고', '내용을 입력해주세요.', 'warning').then(() => bbsCnInput.focus());
            return;
        }
        if(bbsCn.length >= 2000) {
            Swal.fire('경고', '내용이 2000자를 초과했습니다.', 'error').then(() => bbsCnInput.focus());
            return;
        }

        const form = document.getElementById('updateForm');
        const formData = new FormData(form);

        axios.post('/board/updateAxios', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
        })
        .then(res => {
            if(res.data.result === 'success') {
                Swal.fire('수정 완료', '게시글이 성공적으로 수정되었습니다.', 'success')
                .then(() => location.href = '/board/detail?bbsNo=${boardVO.bbsNo}');
            } else {
                Swal.fire('실패', res.data.message || '수정 중 오류가 발생했습니다.', 'error');
            }
        })
        .catch(err => {
            console.error(err);
            Swal.fire('에러', '서버와의 통신에 실패했습니다.', 'error');
        });
    }
</script>