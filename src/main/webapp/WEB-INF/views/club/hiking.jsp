<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="/js/common-alert.js"></script>


<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal.EmpVO" var="userIdTest"/>
</sec:authorize>


<script type="text/javascript">
    //변수명 안겹치게,,
    const myEmpId = "${userIdTest.empId}";
</script>


<style>
    :root {
        --bs-card-border-radius: 0.625rem;
        --bs-card-box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        --bs-body-bg: #f4f7ff;
        --club-primary-color: #2ECC71; /* ⛰️ 등산 동호회 상징색: 싱그러운 초록색 */
    }

    body {
        background-color: var(--bs-body-bg) !important;
        font-family: "Public Sans", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }

    .card {
        border: none;
        border-radius: var(--bs-card-border-radius);
        box-shadow: var(--bs-card-box-shadow);
    }

    .bg-label-primary-custom {
        background-color: #e8fadf !important;
        color: var(--club-primary-color) !important;
        font-weight: 600;
        padding: 0.4em 0.8em;
    }

    /* 갤러리 이미지 모션 */
    .gallery-img-wrapper {
        overflow: hidden;
        border-radius: var(--bs-card-border-radius) var(--bs-card-border-radius) 0 0;
    }
    .gallery-img-wrapper img { transition: transform 0.3s ease; }
    .gallery-img-wrapper:hover img { transform: scale(1.05); }

    /* 상단 탭 (폴더형 디자인) */
    .project-tabs-container { background-color: var(--bs-body-bg); padding: 0; }
    .project-tabs { display: flex; gap: 5px; align-items: flex-end; height: 48px; margin-bottom: 0; }
    .project-tab-btn {
        border: none; background: #e0e5f2; color: #707eae;
        padding: 10px 25px; font-size: 0.95rem; font-weight: 700;
        border-radius: 12px 12px 0 0; cursor: pointer; height: 40px;
        transition: all 0.2s ease; display: flex; align-items: center; gap: 6px;
    }
    .project-tab-btn:hover { background: #d4dcf0; }
    .project-tab-btn.active {
        background: #fff; color: var(--club-primary-color);
        height: 48px; box-shadow: 0 -5px 10px rgba(0,0,0,0.02);
    }

    /* 본문 영역 고정 높이 & 스크롤 */
    .club-tab-content {
        border-radius: 0 12px 12px 12px; height: 680px;
        overflow-y: auto; overflow-x: hidden;
    }
    .club-tab-content::-webkit-scrollbar { width: 6px; }
    .club-tab-content::-webkit-scrollbar-track { background: transparent; }
    .club-tab-content::-webkit-scrollbar-thumb { background-color: #cdd4df; border-radius: 10px; }
    .club-tab-content::-webkit-scrollbar-thumb:hover { background-color: #a1acb8; }

    /* 소개 탭 UI 요소 */
    .intro-box {
        background-color: #f8f9fc;
        border-left: 4px solid var(--club-primary-color);
        transition: all 0.2s ease;
    }
    .intro-box:hover { background-color: #f0f3fb; }
    .executive-box { border: 1px dashed #d9dee3; background-color: #fff; }

    /* 멤버 칩 (구성원용) */
    .member-chip {
        display: inline-flex; align-items: center; background-color: #fff;
        border: 1px solid #e4e6ef; border-radius: 20px;
        padding: 4px 12px 4px 4px; font-size: 0.8rem; color: #566a7f;
        box-shadow: 0 1px 2px rgba(0,0,0,0.02); transition: transform 0.1s ease; cursor: default;
    }
    .member-chip:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.05); }
    .member-chip-avatar {
        width: 32px; height: 32px; border-radius: 50%;
        background-color: var(--club-primary-color); color: #fff;
        display: flex; align-items: center; justify-content: center;
        font-weight: bold; font-size: 0.65rem; margin-right: 6px;
    }

    /* 공지사항 테이블 */
    #noticeTb, #noticeTb tbody tr, #noticeTb tbody td {
        background-color: #ffffff !important;
        border-bottom: 1px solid #f0f2f5 !important;
        transition: background-color 0.15s ease-in-out; cursor: pointer;
    }
    #noticeTb tbody tr:hover td { background-color: #f5fcf7 !important; }

    /* 페이징 블럭 */
    #tdPagingArea, #galleryPagingArea { text-align: center; padding: 0.5rem 0 !important; background-color: #ffffff !important; }
    #tdPagingArea .pagination, #galleryPagingArea .pagination { justify-content: center !important; margin-bottom: 0; }
    #tdPagingArea .pagination .page-link, #galleryPagingArea .pagination .page-link { border: none; margin: 0 3px; border-radius: 5px !important; color: #2f353e; transition: all 0.2s; }
    #tdPagingArea .pagination .page-link:hover, #galleryPagingArea .pagination .page-link:hover { background-color: #e2e6ea; }
    #tdPagingArea .pagination .page-item.active .page-link, #galleryPagingArea .pagination .page-item.active .page-link { background-color: var(--club-primary-color) !important; color: #fff !important; }

    /* 공지사항 목록 제목(링크) 스타일 */
    #notice-tbody a { text-decoration: none; color: #435971; transition: color 0.2s ease; }
    #notice-tbody a:hover { color: var(--club-primary-color); text-decoration: underline; }
</style>


<div class="row g-4 mb-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
                <span class="material-icons" style="color: #696cff; font-size: 32px;">diversity_3</span>

                <div style="display: flex; align-items: baseline; gap: 8px;">
                    <span style="font-size: x-large; font-weight: 800;">사내동호회</span>
                    <span style="font-weight: normal; color: #717171; font-size: 15px;">| 피크(Peak)</span>
                </div>
            </div>

            <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
                사내 등산 동호회 피크(Peak) 입니다. 가입 후 많은 활동 바랍니다.
            </div>
        </div>

    </div>

    <div class="col-12">
        <div class="project-tabs-container d-flex justify-content-between align-items-end">
            <div class="project-tabs" id="clubTabs" role="tablist">
                <button class="project-tab-btn active" id="intro-tab" data-bs-toggle="tab" data-bs-target="#intro" type="button" role="tab">
                    <span class="material-icons" style="font-size: 18px;">info</span> 동호회 소개
                </button>
                <button class="project-tab-btn" id="notice-tab" data-bs-target="#notice" type="button" role="tab" onclick="checkMembership(event, this)">
                    <span class="material-icons" style="font-size: 18px;">campaign</span> 공지사항
                </button>
                <button class="project-tab-btn" id="gallery-tab" data-bs-target="#gallery" type="button" role="tab" onclick="checkMembership(event, this)">
                    <span class="material-icons" style="font-size: 18px;">photo_library</span> 포토갤러리
                </button>
            </div>

            <c:if test="${!isMember}">
                <div class="mb-2 pe-2">
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#joinModal" style="background-color: var(--club-primary-color); border-color: var(--club-primary-color);">
                        <span class="material-icons align-middle me-1" style="font-size: 18px;">person_add</span> 가입하기
                    </button>
                </div>
            </c:if>
        </div>

        <div class="tab-content bg-white p-4 shadow-sm club-tab-content" id="clubTabContent">

            <div class="tab-pane fade show active" id="intro" role="tabpanel" aria-labelledby="intro-tab">

                <div class="row h-100">

                    <!-- 대표 이미지 구역 -->

                    <div class="col-md-5 text-center mb-4 mb-md-0 d-flex flex-column pt-4 align-items-center justify-content-center">
                        <div class="visual-container shadow-lg" style="width: 100%; max-width: 450px; /* 320px에서 450px로 증가 */ aspect-ratio: 1 / 1; border-radius: 50%; overflow: hidden; border: 8px solid #fff; background-color: #e9ecef;">

                            <img src="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=500&auto=format&fit=crop"
                                 alt="등산 동호회"
                                 style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease;"
                                 onmouseover="this.style.transform='scale(1.1)'"
                                 onmouseout="this.style.transform='scale(1)'">
                        </div>
                        <div class="mt-4">
                            <span class="badge bg-light text-muted border px-3 py-2 rounded-pill shadow-sm">오늘도 안전한 산행 되세요 ⛰️</span>
                        </div>
                    </div>
                    <!-- 대표 이미지 구역 -->




                    <div class="col-md-7 d-flex flex-column ps-md-4 pe-md-3 pt-3 h-100">

                        <div class="mb-2">
                            <h4 class="fw-bolder mb-1" style="color: #435971; letter-spacing: -0.5px;">
                                사내 등산 동호회 <span style="color: var(--club-primary-color);">"피크"</span>
                            </h4>
                        </div>

                        <div class="d-flex flex-wrap gap-2 mb-3">
                            <span class="badge rounded-pill bg-label-primary-custom px-3 py-2 fs-6 shadow-sm">
                                <span class="material-icons align-middle me-1" style="font-size: 16px;">groups</span> ${memberCount}명 활동 중
                            </span>
                            <span class="badge rounded-pill bg-label-primary-custom px-3 py-2 fs-6 shadow-sm">
                                <span class="material-icons align-middle me-1" style="font-size: 16px;">event</span>
                                <fmt:formatDate value="${clubVO.clubBgngDt}" pattern="yyyy-MM-dd" /> 설립
                            </span>
                        </div>

                        <div class="intro-box p-3 mb-4 rounded-4 shadow-sm">
                            <h6 class="fw-bold mb-2 d-flex align-items-center" style="color: var(--club-primary-color);">
                                <span class="material-icons me-2" style="font-size: 20px;">auto_awesome</span> About Us
                            </h6>
                            <p class="text-muted mb-0" style="line-height: 1.75; font-size: 0.95rem; white-space: pre-wrap;">${clubVO.clubCn}</p>
                        </div>

                        <div class="executive-box p-4 rounded-4 mb-3 shadow-sm">

                            <div class="d-flex align-items-center gap-3 mb-3 pb-3 border-bottom">
                                <div>
                                    <h6 class="fw-bold text-dark mb-0 fs-6">임원진 안내</h6>
                                    <p class="text-muted mb-0" style="font-size: 0.8rem;">회장: 000 대리</p>
                                </div>
                            </div>

                            <div>
                                <h6 class="fw-bold text-dark mb-2 fs-6 d-flex align-items-center">
                                    <span class="material-icons text-warning me-1" style="font-size: 18px;">stars</span> 함께하는 멤버들
                                </h6>
                                <div id="club-members-container" class="d-flex flex-wrap gap-2 p-1" style="max-height: 120px; overflow-y: auto;">
                                    <span class="text-muted small">멤버 목록을 불러오는 중... 🚀</span>
                                </div>
                            </div>

                        </div>

                        <div class="mt-auto d-flex justify-content-end pb-2">
                            <c:if test="${isMember}">
                                <button class="btn btn-outline-danger btn-sm rounded-pill px-4 shadow-sm" onclick="leaveClub()">
                                    <span class="material-icons align-middle me-1" style="font-size: 16px;">exit_to_app</span> 탈퇴하기
                                </button>
                            </c:if>
                        </div>

                    </div>


                </div>
            </div>


            <!-- 공지사항 탭 시작 -->
            <div class="tab-pane fade" id="notice" role="tabpanel" aria-labelledby="notice-tab">

                <!-- 공지사항 리스트 영역 (상세 보기 진입 시 이 전체가 숨겨짐) -->
                <div id="notice-list-area">

                    <!-- 공지등록 버튼과 검색창을 한 줄로 깔끔하게 묶음 -->
                    <div class="d-flex justify-content-between align-items-center mb-3 pt-2">

                        <!-- 왼쪽: 공지 등록 버튼 (회장일 때만 보임) -->
                        <div>
                            <c:if test="${isPresident}">
                                <button class="btn btn-sm shadow-sm d-inline-flex align-items-center px-3" onclick="goToWrite()" style="background-color: var(--club-primary-color); color: white; border-radius: 6px;">
                                    <span class="material-icons me-1" style="font-size: 16px;">edit</span> 공지 등록
                                </button>
                            </c:if>
                        </div>

                        <!-- 오른쪽: 검색 영역 -->
                        <div class="input-group input-group-sm shadow-sm" style="width: 320px; border-radius: 6px; overflow: hidden;">
                            <select name="noticeMode" class="form-select bg-light border-0" id="noticeSearchCondition" style="max-width: 100px;">
                                <option value="clubNtcTtl" selected>제목</option>
                                <option value="clubNtcCn">내용</option>
                            </select>
                            <input name="noticeKeyword" type="text" class="form-control border-0" id="noticeSearchKeyword" placeholder="검색어 입력">
                            <button class="btn btn-light d-inline-flex align-items-center border-0" type="button" id="btnNoticeSearch">
                                <span class="material-icons fs-6 text-muted">search</span>
                            </button>
                        </div>
                    </div>

                    <!-- 테이블 영역 -->
                    <div class="table-responsive border-bottom mb-2 rounded shadow-sm">
                        <table class="table align-middle mb-0 text-center" id="noticeTb">
                            <thead class="table-light">
                            <tr>
                                <th style="width: 10%;">번호</th>
                                <th style="width: 50%; text-align: left;">제목</th>
                                <th style="width: 15%;">작성자</th>
                                <th style="width: 15%;">등록일</th>
                                <th style="width: 10%;">조회수</th>
                            </tr>
                            </thead>
                            <tbody id="notice-tbody">
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">공지사항을 불러오는 중입니다... 🚀</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- 페이징 영역 -->
                    <div class="bg-white border-0 py-2">
                        <div id="tdPagingArea" class="d-flex justify-content-center w-100">
                        </div>
                    </div>

                </div>
                <!--  notice-list-area 끝 -->

                <!-- 상세 보기 영역 (처음엔 숨김 처리) -->
                <!-- 상세 보기 영역 -->
                <div id="notice-detail-area" style="display: none;">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 id="detail-title" class="m-0 fw-bold" style="color: #435971;"></h4>

                        <!-- 버튼들을 하나로 묶어줍니다 -->
                        <div>
                            <!-- 회장일 때만 공지사항 삭제 가능 -->
                            <c:if test="${isPresident}">
                                <button class="btn btn-sm btn-outline-danger me-1" id="btn-delete-notice">
                                    <span class="material-icons align-middle" style="font-size: 16px;">delete</span> 삭제
                                </button>
                            </c:if>

                            <button class="btn btn-sm btn-outline-secondary" onclick="goToList()">목록으로</button>
                        </div>
                    </div>

                    <div class="text-muted mb-3 pb-2 border-bottom" style="font-size: 0.95rem;">
                        작성자: <span id="detail-writer" class="fw-bold" style="color: #435971;"></span>
                        <span class="mx-2" style="color: #d9dee3;">|</span>
                        작성일: <span id="detail-date"></span>
                        <span class="mx-2" style="color: #d9dee3;">|</span>
                        조회수: <span id="detail-cnt"></span>
                    </div>

                    <div id="detail-content" class="p-4 rounded" style="min-height: 250px; background-color: #f8f9fa; font-size: 0.95rem; line-height: 1.6; white-space: pre-wrap;">
                    </div>
                </div>
                <!--  notice-detail-area 끝 -->


                <!-- 공지사항 작성 영역 (처음엔 숨김 처리) -->
                <div id="notice-write-area" style="display: none;">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                        <h5 class="m-0 fw-bold" style="color: #435971;">
                            <span class="material-icons align-middle me-1 text-primary">edit_document</span>새 공지사항 작성
                        </h5>
                    </div>

                    <div class="bg-white p-4 rounded shadow-sm" style="border: 1px solid #e4e6ef;">
                        <form id="noticeWriteForm">
                            <!-- 제목 입력 -->
                            <div class="mb-3">
                                <label for="write-title" class="form-label fw-bold text-dark">제목</label>
                                <input type="text" class="form-control form-control-lg" id="write-title" placeholder="공지사항 제목을 입력해주세요." required>
                            </div>

                            <!-- 내용 입력 -->
                            <div class="mb-4">
                                <label for="write-content" class="form-label fw-bold text-dark">내용</label>
                                <textarea class="form-control" id="write-content" rows="12" placeholder="공지할 내용을 상세히 적어주세요." style="resize: none;" required></textarea>
                            </div>

                            <!-- 하단 버튼 영역 -->
                            <div class="d-flex justify-content-end gap-2">
                                <button type="button" class="btn btn-light border px-4" onclick="cancelWrite()">취소</button>
                                <button type="button" class="btn text-white px-4" style="background-color: var(--club-primary-color);" onclick="submitNotice()">등록하기</button>
                            </div>
                        </form>
                    </div>
                </div>
                <!--  notice-write-area 끝 -->



            </div>
            <!-- 공지사항 탭 끝  -->


            <!-- 포토 갤러리 탭 시작 -->
            <div class="tab-pane fade" id="gallery" role="tabpanel" aria-labelledby="gallery-tab">

                <!--  갤러리 리스트 영역 -->
                <div id="gallery-list-area">
                    <!-- 공지사항처럼 버튼과 검색창을 한 줄로 깔끔하게 묶음 -->
                    <div class="d-flex justify-content-between align-items-center mb-3 pt-2 pb-3 border-bottom">

                        <!-- 왼쪽: 사진 올리기 버튼 (멤버일 때만 보임) -->
                        <div>
                            <c:if test="${isMember}">
                                <button class="btn btn-sm shadow-sm d-inline-flex align-items-center px-3" onclick="goToGalleryWrite()" style="background-color: var(--club-primary-color); color: white; border-radius: 6px;">
                                    <span class="material-icons me-1" style="font-size: 16px;">add_a_photo</span> 사진 올리기
                                </button>
                            </c:if>
                        </div>

                        <!-- 오른쪽: 검색 영역 (셀렉트 박스 없이 심플하게!) -->
                        <div class="input-group input-group-sm shadow-sm" style="width: 250px; border-radius: 6px; overflow: hidden;">
                            <input name="galleryKeyword" type="text" class="form-control border-0 bg-light" id="gallerySearchKeyword" placeholder="제목/내용/작성자 검색">
                            <button class="btn btn-light d-inline-flex align-items-center border-0" type="button" id="btnGallerySearch">
                                <span class="material-icons fs-6 text-muted">search</span>
                            </button>
                        </div>
                    </div>

                    <!-- 갤러리 리스트 (비동기로 채울 곳) -->
                    <div class="row g-4" id="gallery-list-container">
                        <div class="col-12 text-center text-muted py-5">갤러리를 불러오는 중입니다... 🚀</div>
                    </div>

                    <!-- 갤러리용 페이징.. -->
                    <div class="bg-white border-0 py-3 mt-3">
                        <div id="galleryPagingArea" class="d-flex justify-content-center w-100">
                        </div>
                    </div>

                </div>

                <!--  갤러리 작성 영역 (처음엔 숨김) -->
                <div id="gallery-write-area" style="display: none;">
                    <div class="d-flex justify-content-between align-items-center mb-3 pb-3 border-bottom">
                        <h5 class="m-0 fw-bold" style="color: #435971;">
                            <span class="material-icons align-middle me-1 text-primary">add_photo_alternate</span>사진 등록하기
                        </h5>



                    </div>

                    <div class="bg-white p-4 rounded shadow-sm" style="border: 1px solid #e4e6ef;">
                        <form id="galleryWriteForm" enctype="multipart/form-data">
                            <!-- 제목 입력 -->
                            <div class="mb-3">
                                <label for="gallery-title" class="form-label fw-bold text-dark">사진 제목</label>
                                <input type="text" class="form-control" id="gallery-title" name="clubBbsTtl" placeholder="예: 이번달 모임 후기" required>
                            </div>

                            <!-- 내용 입력 (간단한 설명) -->
                            <div class="mb-3">
                                <label for="gallery-content" class="form-label fw-bold text-dark">사진 설명</label>
                                <textarea class="form-control" id="gallery-content" name="clubBbsCn" rows="3" placeholder="사진에 대한 간단한 설명을 적어주세요."></textarea>
                            </div>

                            <!-- 다중 파일 첨부 (이미지만 가능하게...) -->
                            <div class="mb-4">
                                <label class="form-label fw-bold text-dark">사진 첨부 (최대 5장 첨부 가능)</label>
                                <input class="form-control" type="file" id="gallery_input_file" name="multipartFiles" accept="image/*" multiple onchange="previewImages(event)">
                                <div class="form-text mt-2 text-muted">※ 아래 이미지 박스에서 선택한 사진이 갤러리 대표 사진(썸네일)으로 사용됩니다.</div>

                                <!-- 이미지 미리보기 영역 -->
                                <div id="image-preview-container" class="d-flex flex-wrap gap-2 mt-3 p-2 rounded bg-light" style="min-height: 100px; border: 1px dashed #ccc;">
                                    <span class="text-muted small align-self-center w-100 text-center">선택된 이미지가 없습니다.</span>
                                </div>
                            </div>

                            <!-- 하단 버튼 영역 -->
                            <div class="d-flex justify-content-end gap-2">
                                <button type="button" class="btn btn-light border px-4" onclick="cancelGalleryWrite()">취소</button>
                                <button type="button" class="btn text-white px-4" style="background-color: var(--club-primary-color);" onclick="submitGallery()">등록하기</button>
                            </div>





                        </form>
                    </div>
                </div>

                <!-- 갤러리 상세 보기 영역 (처음엔 숨김 처리) -->
                <!-- 갤러리 상세 보기 영역 -->
                <div id="gallery-detail-area" style="display: none;">
                    <!-- 제목 및 버튼 영역 (공지사항과 통일) -->
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4 id="g-detail-title" class="m-0 fw-bold" style="color: #435971;"></h4>
                        <div>
                            <button class="btn btn-sm btn-outline-danger me-1" id="btn-delete-gallery" style="display: none;">
                                <span class="material-icons align-middle" style="font-size: 16px;">delete</span> 삭제
                            </button>
                            <button class="btn btn-sm btn-outline-secondary" onclick="goToGalleryList()">목록으로</button>
                        </div>
                    </div>

                    <!-- 작성자 정보 영역 (공지사항과 100% 통일) -->
                    <div class="text-muted mb-3 pb-2 border-bottom" style="font-size: 0.95rem;">
                        작성자: <span id="g-detail-writer" class="fw-bold" style="color: #435971;"></span>
                        <span class="mx-2" style="color: #d9dee3;">|</span>
                        작성일: <span id="g-detail-date"></span>
                        <span class="mx-2" style="color: #d9dee3;">|</span>
                        조회수: <span id="g-detail-cnt"></span>
                    </div>

                    <!-- 사진 + 본문 영역 -->
                    <div class="p-4 rounded" style="min-height: 250px; background-color: #f8f9fa;">
                        <!-- 📸 사진 영역 (캐러셀 구조 유지) -->
                        <div class="row justify-content-center mb-4">
                            <div class="col-md-10">
                                <div id="galleryCarousel" class="carousel slide shadow-sm rounded" data-bs-ride="false" style="background-color: #040b14; overflow: hidden;">
                                    <div class="carousel-indicators" id="g-carousel-indicators"></div>
                                    <div class="carousel-inner" id="g-carousel-inner"></div>
                                    <button class="carousel-control-prev" type="button" data-bs-target="#galleryCarousel" data-bs-slide="prev" id="g-carousel-prev">
                                        <span class="carousel-control-prev-icon"></span>
                                    </button>
                                    <button class="carousel-control-next" type="button" data-bs-target="#galleryCarousel" data-bs-slide="next" id="g-carousel-next">
                                        <span class="carousel-control-next-icon"></span>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- 📝 본문 설명 영역 -->
                        <div id="g-detail-content" class="px-2" style="font-size: 1rem; line-height: 1.6; color: #2c3e50; white-space: pre-wrap;">
                        </div>
                    </div>
                </div>
                <!-- 갤러리 상세 보기 영역 끝 -->
            </div>
            <!-- 갤러리 탭 끝 -->




        </div>
    </div>

    <!-- 가입 모달 -->
    <div class="modal fade" id="joinModal" tabindex="-1" aria-labelledby="joinModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header text-white" style="background-color: var(--club-primary-color);">
                    <h5 class="modal-title d-flex align-items-center text-white" id="joinModalLabel">
                        <span class="material-icons me-2">group_add</span> 등산 동호회 페이지 가입 신청
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <form id="joinForm">
                        <div class="mb-3">
                            <label for="joinGreeting" class="form-label fw-bold">가입 인사글</label>
                            <textarea class="form-control" id="joinGreeting" rows="4"
                                      placeholder="좋아하는 산이나 가입하게 된 계기 등 간단한 인사를 남겨주세요!(최대 150자)"
                                      maxlength="150" required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer bg-light border-top-0">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" style="background-color: var(--club-primary-color); border:none;" onclick="submitJoinRequest()">가입하기</button>
                </div>
            </div>
        </div>
    </div>
    <!-- 가입 모달 끝 -->


</div>

<script type="text/javascript">
    const isMember = ${isMember};

    // 탭 누를때마다 실행되는 회원여부 확인
    function checkMembership(event, element) {
        if (!isMember) {
            event.preventDefault();
            event.stopPropagation();

            // (알람 리팩토링) 비회원 접근 제한 경고창
            AppAlert.warning('회원 전용 메뉴', '동호회 가입 후 조회 가능합니다.', null, 'lock');
            return;

        } else if (isMember) {

            const tab = new bootstrap.Tab(element);
            tab.show();

            // 탭 실행되면,,
            if (element.id === 'notice-tab') {

                // 공지사항 영역 초기화
                document.getElementById('notice-detail-area').style.display = 'none';
                document.getElementById('notice-write-area').style.display = 'none';
                document.getElementById('notice-list-area').style.display = 'block';

                //공지사항 작성 폼 비우기! (reset)
                const noticeForm = document.getElementById('noticeWriteForm');
                if (noticeForm) noticeForm.reset();

                loadClubNotices();

            } else if (element.id === 'gallery-tab') {

                // 포토갤러리 영역 초기화
                document.getElementById('gallery-detail-area').style.display = 'none';
                document.getElementById('gallery-write-area').style.display = 'none';
                document.getElementById('gallery-list-area').style.display = 'block';

                // 포토갤러리 작성 폼 비우기! (reset)
                const galleryForm = document.getElementById('galleryWriteForm');
                if (galleryForm) galleryForm.reset();

                // 갤러리 이미지 미리보기 영역도 초기 상태로 되돌리기!!!!!!!!!!!!!!!!
                const previewContainer = document.getElementById('image-preview-container');
                if (previewContainer) {
                    previewContainer.innerHTML = '<span class="text-muted small align-self-center w-100 text-center">선택된 이미지가 없습니다.</span>';
                }

                loadGalleryList();
            }
        }
    }

        //동호회 가입하기
        function submitJoinRequest() {
            const greetingStr = document.getElementById('joinGreeting').value;
            if (greetingStr.trim() === '') {
                // (알람 리팩토링) 필수 입력 누락 경고창
                AppAlert.warning('잠시만요!', '가입 인사글을 작성해주세요.', 'joinGreeting');
                return;
            }

            // 2. 글자 수 150자 제한 (HTML maxlength로 1차 방어했지만 JS로 복붙 2차 방어)
            if (joinGreeting.length > 150) {
                AppAlert.warning('글자 수 초과', '가입 인사는 최대 150자까지만 입력할 수 있습니다.<br><span class="text-danger">(현재: ' + joinGreeting.length + '자)</span>', 'joinGreeting', 'text_fields');
                return;
            }

            const data = {
                "clubNo": 3,
                "clubJoinGret": greetingStr
            };
            axios.post("/club/join", data, {
                headers: {"Content-Type": "application/json;charset=utf-8"}
            })
                .then(response => {
                    // (알람 리팩토링) 가입 성공 알림창
                    AppAlert.success('환영합니다!', '가입이 완료되었습니다. 산내음 <br/>가득한 활동을 시작해보세요!')
                        .then(() => {
                            const joinModal = bootstrap.Modal.getInstance(document.getElementById('joinModal'));
                            if (joinModal) joinModal.hide();
                            document.getElementById('joinGreeting').value = '';
                            location.reload();
                        });
                })
                .catch(err => {
                    console.error("가입 신청 실패 : ", err);
                    // (알람 리팩토링) 서버 통신 에러 알림
                    AppAlert.error('가입 실패', '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
                });
        }

        // 동호회 탈퇴하기
        function leaveClub() {
            // (알람 리팩토링) 컨펌창으로 교체
            AppAlert.confirm('정말로 탈퇴하시겠습니까?', "등산 동호회 '피크'를 떠나시게 됩니다.", '탈퇴하기', '머무르기', 'warning_amber', 'danger')
                .then((result) => {
                    if (result.isConfirmed) {
                        const clubNo = 3;

                        const data = {
                            "clubNo": clubNo
                        };

                        axios.post("/club/leave", data, {
                            headers: {"Content-Type": "application/json;charset=utf-8"}
                        })
                            .then(response => {
                                if (response.data === "SUCCESS") {
                                    // (알람 리팩토링) 탈퇴 성공 알림
                                    AppAlert.success('탈퇴 완료', '언젠가 다시 산 위에서 뵙기를 바랍니다.')
                                        .then(() => {
                                            location.reload();
                                        });
                                } else {
                                    // (알람 리팩토링) 탈퇴 실패 알림
                                    AppAlert.error('탈퇴 실패', '탈퇴 처리에 실패했습니다. 다시 시도해주세요.');
                                }
                            })
                            .catch(err => {
                                console.error("동호회 탈퇴 에러 : ", err);
                                // (알람 리팩토링) 서버 통신 에러 알림
                                AppAlert.error('오류 발생', '서버 오류가 발생했습니다.');
                            });
                    }
                });
        }

        // ==========================================
        // 구성원(멤버) 비동기 로딩 로직
        // ==========================================
        function loadClubMembers() {
            const clubNo = 3;
            axios.get(`/club/members?clubNo=\${clubNo}`)
                .then(response => {
                    const members = response.data;
                    const container = document.getElementById('club-members-container');
                    container.innerHTML = '';

                    if (!members || members.length === 0) {
                        container.innerHTML = '<span class="text-muted small">아직 가입한 멤버가 없습니다. 첫 멤버가 되어주세요!</span>';
                        return;
                    }

                    let html = '';
                    members.forEach(m => {
                        const firstLetter = m.empNm ? m.empNm.substring(0, 1) : '?';
                        const jbps = m.empJbgd ? m.empJbgd : '사원';
                        const dept = m.deptNm ? m.deptNm : '소속없음';

                        let avatarHtml = '';
                        if (m.avtSaveNm && m.avtSaveNm !== 'NONE') {
                            avatarHtml = `<img src="/avatar/displayAvt?fileName=\${m.avtSaveNm}" alt="Avatar" class="member-chip-avatar" style="object-fit: cover; background-color: transparent;">`;
                        } else {
                            avatarHtml = `<div class="member-chip-avatar">\${firstLetter}</div>`;
                        }

                        html += `
                        <div class="member-chip" title="\${dept} \${m.empNm} \${jbps}">
                            \${avatarHtml}
                            <span class="fw-bold text-dark">\${m.empNm}(\${jbps}) <span style="color: #a1acb8; font-weight: normal; margin-left: 2px;">| \${dept}</span></span>
                        </div>
                    `;
                    });
                    container.innerHTML = html;
                })
                .catch(error => {
                    console.error("멤버 불러오기 실패:", error);
                    document.getElementById('club-members-container').innerHTML = '<span class="text-danger small">멤버 정보를 불러오지 못했습니다.</span>';
                });
        }

        document.addEventListener("DOMContentLoaded", function () {
            loadClubMembers();
        });

        //공지사항 비동기 로직
        function loadClubNotices() {
            const clubNo = 3;

            let data = {
                "currentPage": 1,
                "clubNo": clubNo,
                "mode": "",
                "keyword": ""
            };

            axios.post("/club/clubNoticeListAxios", data, {
                headers: {"Content-Type": "application/json;charset=utf-8"}
            })
                .then(response => {
                    listShowFn(response.data);
                })
                .catch(error => {
                    console.error("공지사항 불러오기 실패:", error);
                    document.getElementById('notice-tbody').innerHTML =
                        '<tr><td colspan="5" class="text-center text-danger py-4">데이터를 불러오지 못했습니다.</td></tr>';
                });
        }

        function listShowFn(articlePage) {
            const clubNoticeVOList = articlePage.content;
            let str = '';

            if (!clubNoticeVOList || clubNoticeVOList.length === 0) {
                document.getElementById('notice-tbody').innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">등록된 공지사항이 없습니다.</td></tr>';
                document.getElementById("tdPagingArea").innerHTML = "";
                return;
            }

            clubNoticeVOList.forEach(function (clubNoticeVO) {
                const dateObj = new Date(clubNoticeVO.clubNtcDt);
                const formattedDate = dateObj.getFullYear() + '-' +
                    String(dateObj.getMonth() + 1).padStart(2, '0') + '-' +
                    String(dateObj.getDate()).padStart(2, '0');

                str += `
                    <tr>
                        <td>\${clubNoticeVO.rnum}</td>
                        <td class="text-start fw-bold">
                            <a href="#" onclick="goToDetail(\${clubNoticeVO.clubNtcNo}); return false;">
                                \${clubNoticeVO.clubNtcTtl}
                            </a>
                        </td>
                        <td>\${clubNoticeVO.empNm}</td>
                        <td>\${formattedDate}</td>
                        <td class="text-muted">\${clubNoticeVO.clubNtcCnt}</td>
                    </tr>
                `;
            });

            document.getElementById("notice-tbody").innerHTML = str;
            document.getElementById("tdPagingArea").innerHTML = articlePage.pagingArea || "";
        }


        //공지사항 검색해주는 함수..
        const btnSearch = document.getElementById("btnNoticeSearch");
        btnSearch.addEventListener("click", () => {
            const data = {
                "currentPage": 1,
                "clubNo": 3,
                "mode": document.querySelector("select[name='noticeMode']").value || "",
                "keyword": document.querySelector("input[name='noticeKeyword']").value || ""
            };

            axios.post("/club/clubNoticeListAxios", data, {headers: {"Content-Type": "application/json;charset=utf-8"}})
                .then(response => listShowFn(response.data))
                .catch(err => console.error(err));
        });



        const noticeSearchInput = document.getElementById("noticeSearchKeyword");

        if (noticeSearchInput) {
            noticeSearchInput.addEventListener("keypress", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    btnSearch.click();
                }
            });
        }

        // [공용 페이징 블록 핸들러 함수]
        function listFn(url, currentPage, mode, keyword) {
            let data = {
                "currentPage": currentPage,
                "mode": mode,
                "keyword": keyword,
                "clubNo": 3
            };
            axios.post(url, data, {
                headers: {"Content-Type": "application/json;charset=utf-8"}
            })
                .then(response => {
                    if (mode === 'gallery') {
                        galleryListShowFn(response.data);
                    } else {
                        listShowFn(response.data);
                    }
                })
                .catch(err => {
                    console.error("페이징 이동 에러: ", err);
                });
        }

        // 공지사항 상세 보기 이동 함수
        function goToDetail(clubNtcNo) {
            axios.get(`/club/noticeDetail?clubNtcNo=\${clubNtcNo}`)
                .then(response => {
                    const notice = response.data;

                    const dateObj = new Date(notice.clubNtcDt);
                    const formattedDate = dateObj.getFullYear() + '-' +
                        String(dateObj.getMonth() + 1).padStart(2, '0') + '-' +
                        String(dateObj.getDate()).padStart(2, '0');

                    const jbgd = notice.empJbgd ? notice.empJbgd : '사원';
                    const dept = notice.deptNm ? notice.deptNm : '소속없음';

                    let avatarTag = (notice.avtSaveNm && notice.avtSaveNm !== 'NONE')
                        ? `<img src="/avatar/displayAvt?fileName=\${notice.avtSaveNm}" alt="Avatar" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; margin-right: 8px; border: 1px solid #eee;">`
                        : `<span class="material-icons align-middle text-primary me-2" style="font-size: 40px;">account_circle</span>`;
                    document.getElementById('detail-writer').innerHTML = `\${avatarTag} [\${dept}] \${notice.empNm}(\${jbgd})`;
                    document.getElementById('detail-title').innerText = notice.clubNtcTtl;
                    document.getElementById('detail-date').innerText = formattedDate;
                    document.getElementById('detail-cnt').innerText = notice.clubNtcCnt;
                    document.getElementById('detail-content').innerHTML = notice.clubNtcCn;
                    const deleteBtn = document.getElementById('btn-delete-notice');
                    if (deleteBtn) {
                        deleteBtn.setAttribute('onclick', `deleteNotice(\${notice.clubNtcNo})`);
                    }

                    document.getElementById('notice-list-area').style.display = 'none';
                    document.getElementById('notice-detail-area').style.display = 'block';
                })
                .catch(error => {
                    console.error("공지 상세 조회 에러:", error);
                    // (알람 리팩토링) 상세 조회 에러
                    AppAlert.error('오류 발생', '상세 정보를 불러오는 중 오류가 발생했습니다.');
                });
        }

        // 다시 목록으로 돌아가는 함수
        function goToList() {
            document.getElementById('notice-detail-area').style.display = 'none';
            document.getElementById('notice-write-area').style.display = 'none';
            document.getElementById('notice-list-area').style.display = 'block';
            loadClubNotices();
        }

        // 공지사항 글쓰기 폼으로 이동하는 함수
        function goToWrite() {
            document.getElementById('write-title').value = '';
            document.getElementById('write-content').value = '';
            document.getElementById('notice-list-area').style.display = 'none';
            document.getElementById('notice-detail-area').style.display = 'none';
            document.getElementById('notice-write-area').style.display = 'block';
        }

        // 공지사항 작성 취소 함수
        function cancelWrite() {
            // (알람 리팩토링) 컨펌창 적용
            AppAlert.confirm('작성을 취소하시겠습니까?', '작성 중인 내용이 모두 사라집니다.', '네, 취소합니다', '계속 작성', 'warning_amber', 'warning')
                .then((result) => {
                    if (result.isConfirmed) {
                        goToList();
                    }
                });
        }

        // 서버로 공지사항 등록(INSERT) 보내는 함수
        function submitNotice() {
            const title = document.getElementById('write-title').value.trim();
            const content = document.getElementById('write-content').value.trim();

            if (!title) {
                // (알람 리팩토링) 경고창 적용
                AppAlert.warning('입력 확인', '제목을 입력해주세요.', 'write-title');
                return;
            }
            if (!content) {
                // (알람 리팩토링) 경고창 적용
                AppAlert.warning('입력 확인', '내용을 입력해주세요.', 'write-content');
                return;
            }

            const data = {clubNo: 3, clubNtcTtl: title, clubNtcCn: content};
            axios.post("/club/noticeWrite", data, {
                headers: {"Content-Type": "application/json;charset=utf-8"}
            })
                .then(response => {
                    if (response.data === "SUCCESS") {
                        // (알람 리팩토링) 성공 후 자동 닫힘 알림
                        AppAlert.autoClose('등록 완료!', '공지사항이 성공적으로 등록되었습니다.', 'check_circle', 'success', 1500)
                            .then(() => {
                                goToList();
                            });
                    }
                })
                .catch(error => {
                    console.error("공지사항 등록 실패:", error);
                    // (알람 리팩토링) 서버 통신 에러
                    AppAlert.error('오류 발생', '등록 중 오류가 발생했습니다.');
                });
        }//공지사항 작성 끝

        // 공지사항 삭제 (상태 업데이트) 함수
        function deleteNotice(clubNtcNo) {
            // (알람 리팩토링) 삭제 컨펌창 적용
            AppAlert.confirm('공지사항을 삭제하시겠습니까?', '삭제된 공지는 복구할 수 없습니다.', '삭제', '취소', 'delete', 'danger')
                .then((result) => {
                    if (result.isConfirmed) {
                        const data = clubNtcNo;

                        axios.post("/club/noticeDelete", data, {
                            headers: {"Content-Type": "application/json;charset=utf-8"}
                        })
                            .then(response => {
                                // (알람 리팩토링) 자동 닫힘 성공 알림
                                AppAlert.autoClose('삭제 완료', '공지사항이 삭제되었습니다.', 'check_circle', 'success')
                                    .then(() => {
                                        goToList();
                                    });
                            })
                            .catch(error => {
                                console.error("공지사항 삭제 에러:", error);
                                // (알람 리팩토링) 에러 알림
                                AppAlert.error('오류 발생', '삭제 중 오류가 발생했습니다.');
                            });
                    }
                });
        }

        // 갤러리 작성 폼 켜기/끄기
        function goToGalleryWrite() {
            document.getElementById('gallery-list-area').style.display = 'none';
            document.getElementById('gallery-write-area').style.display = 'block';
        }

        // 포토갤러리 취소 버튼
        function cancelGalleryWrite() {
            // (알람 리팩토링) 작성 취소 컨펌창
            AppAlert.confirm('작성을 취소하시겠습니까?', '선택한 사진과 내용이 초기화됩니다.', '네, 취소합니다', '계속 작성', 'warning_amber', 'warning')
                .then((result) => {
                    if (result.isConfirmed) {
                        document.getElementById('galleryWriteForm').reset();
                        document.getElementById('image-preview-container').innerHTML = '<span class="text-muted small align-self-center w-100 text-center">선택된 이미지가 없습니다.</span>';
                        document.getElementById('gallery-write-area').style.display = 'none';
                        document.getElementById('gallery-list-area').style.display = 'block';
                    }
                });
        }// 갤러리 작성 취소 끝

        // 이미지 다중 선택 미리보기 및 검증
        function previewImages(event) {
            const container = document.getElementById('image-preview-container');
            container.innerHTML = '';
            const fileInput = event.target;
            const files = fileInput.files;
            if (files.length === 0) {
                container.innerHTML = '<span class="text-muted small align-self-center w-100 text-center">선택된 이미지가 없습니다.</span>';
                return;
            }

            if (files.length > 5) {
                // (알람 리팩토링) 용량 초과 에러창
                AppAlert.error('첨부 용량 초과', '사진은 한 번에 최대 5장까지만 등록할 수 있습니다.', 'gallery_input_file');
                fileInput.value = '';
                container.innerHTML = '<span class="text-muted small align-self-center w-100 text-center text-danger">사진을 5장 이하로 다시 선택해주세요.</span>';
                return;
            }

            for (let i = 0; i < files.length; i++) {
                if (!files[i].type.startsWith('image/')) {
                    // (알람 리팩토링) 파일 형식 에러창
                    AppAlert.error('잘못된 파일 형식', '이미지 파일(JPG, PNG, GIF 등)만 업로드할 수 있습니다.', 'gallery_input_file');
                    fileInput.value = '';
                    container.innerHTML = '<span class="text-muted small align-self-center w-100 text-center text-danger">올바른 이미지 파일만 다시 선택해주세요.</span>';
                    return;
                }
            }

            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                const reader = new FileReader();

                reader.onload = function (e) {
                    const isChecked = i === 0 ? 'checked' : '';
                    const imgHtml = `
                <div class="position-relative d-inline-block m-1" style="width: 120px;">
                    <div style="width: 120px; height: 120px; overflow: hidden; border-radius: 8px; border: 1px solid #ddd;">
                        <img src="\${e.target.result}" style="width: 100%; height: 100%; object-fit: cover;">
                    </div>
                    <div class="text-center mt-1">
                        <input class="form-check-input border-secondary" type="radio" name="repImgRadio" id="repImg\${i}" value="\${i}" \${isChecked} style="cursor: pointer;">
                        <label class="form-check-label small fw-bold" for="repImg\${i}" style="cursor: pointer; color: #435971;">대표 사진 지정</label>
                    </div>
                </div>
                `;
                    container.innerHTML += imgHtml;
                }
                reader.readAsDataURL(file);
            }
        };//이미지 미리보기

        // 포토갤러리 등록
        function submitGallery() {
            const title = document.getElementById('gallery-title').value.trim();
            const content = document.getElementById('gallery-content').value.trim();
            const fileInput = document.getElementById('gallery_input_file');
            const files = fileInput.files;

            if (!title) {
                // (알람 리팩토링) 필수값 누락 경고
                AppAlert.warning('입력 확인', '사진 제목을 입력해 주세요.', 'gallery-title');
                return;
            }
            if (files.length === 0) {
                // (알람 리팩토링) 파일 누락 경고
                AppAlert.warning('사진 누락', '갤러리에 등록할 사진을 최소 1장 이상 선택해 주세요.', 'gallery_input_file');
                return;
            }
            if (files.length > 5) {
                // (알람 리팩토링) 용량 초과 경고
                AppAlert.error('첨부 용량 초과', '사진은 최대 5장까지만 등록 가능합니다. 다시 확인해주세요.', 'gallery_input_file');
                return;
            }

            // (알람 리팩토링) 등록 확인 컨펌창
            AppAlert.confirm('등록하시겠습니까?', `총 \${files.length}장의 사진이 갤러리에 업로드됩니다.`, '등록하기', '취소', 'upload', 'primary')
                .then((result) => {
                    if (result.isConfirmed) {
                        const formData = new FormData();
                        formData.append("clubNo", 3);
                        formData.append("clubBbsTtl", title);
                        formData.append("clubBbsCn", content);

                        const repRadio = document.querySelector('input[name="repImgRadio"]:checked');
                        const repIndex = repRadio ? parseInt(repRadio.value) : 0;

                        formData.append("multipartFiles", files[repIndex]);

                        for (let i = 0; i < files.length; i++) {
                            if (i !== repIndex) {
                                formData.append("multipartFiles", files[i]);
                            }
                        }

                        axios.post("/club/galleryWrite", formData, {
                            headers: {"Content-Type": "multipart/form-data"}
                        })
                            .then(response => {
                                if (response.data === "SUCCESS" || response.status === 200) {
                                    // (알람 리팩토링) 성공 후 자동 닫힘 알림
                                    AppAlert.autoClose('등록 완료!', '사진이 성공적으로 등록되었습니다!', 'check_circle', 'success')
                                        .then(() => {
                                            document.getElementById('galleryWriteForm').reset();
                                            document.getElementById('image-preview-container').innerHTML = '<span class="text-muted small align-self-center w-100 text-center">선택된 이미지가 없습니다.</span>';
                                            document.getElementById('gallery-write-area').style.display = 'none';
                                            document.getElementById('gallery-list-area').style.display = 'block';
                                            loadGalleryList();
                                        });
                                }
                            })
                            .catch(error => {
                                console.error("갤러리 등록 에러:", error);
                                // (알람 리팩토링) 업로드 실패 에러 알림
                                AppAlert.error('업로드 실패', '사진 등록 중 오류가 발생했습니다.');
                            });
                    }
                });
        }// 등록끝

        // 포토갤러리 비동기 로직 (목록 불러오기)
        function loadGalleryList(currentPage = 1) {
            const clubNo = 3;
            let data = {
                "currentPage": currentPage,
                "clubNo": clubNo,
                "mode": "gallery",
                "keyword": ""
            };
            axios.post("/club/clubBoardListAxios", data, {
                headers: {"Content-Type": "application/json;charset=utf-8"}
            })
                .then(response => {
                    galleryListShowFn(response.data);
                })
                .catch(error => {
                    console.error("갤러리 불러오기 실패:", error);
                    document.getElementById('gallery-list-container').innerHTML =
                        '<div class="col-12 text-center text-danger py-5">데이터를 불러오지 못했습니다.</div>';
                });
        }

        // 포토갤러리 화면 그리기
        function galleryListShowFn(articlePage) {
            const galleryList = articlePage.content;
            const container = document.getElementById('gallery-list-container');
            let str = '';

            if (!galleryList || galleryList.length === 0) {
                container.innerHTML = '<div class="col-12 text-center text-muted py-5">아직 등록된 사진이 없습니다. 첫 번째 사진을 올려주세요!</div>';
                document.getElementById("galleryPagingArea").innerHTML = "";
                return;
            }

            galleryList.forEach(function (item) {
                let imgSrc = `/upload\${item.thumbnailPath}`;

                let badgeHtml = "";
                if (item.fileCnt > 1) {
                    badgeHtml = `
                    <div class="position-absolute top-0 end-0 m-2 px-2 py-1 bg-dark text-white rounded-pill d-flex align-items-center shadow-sm" style="opacity: 0.8; font-size: 0.75rem;">
                        <span class="material-icons me-1" style="font-size: 13px;">filter_none</span>
                        \${item.fileCnt}
                    </div>
                `;
                }

                str += `
                <div class="col-md-4">
                    <div class="card h-100 shadow-sm border-0" onclick="goToGalleryDetail(\${item.clubBbsNo})" style="cursor: pointer; transition: transform 0.2s ease;">
                        <div class="gallery-img-wrapper position-relative" style="height: 220px; background-color: #040b14;">
                            <img src="\${imgSrc}" class="card-img-top w-100 h-100" style="object-fit: cover;" alt="갤러리 썸네일">
                            \${badgeHtml}
                        </div>
                        <div class="card-body p-3">
                            <h6 class="card-title fw-bold text-truncate mb-2" style="color: #435971;">\${item.clubBbsTtl}</h6>
                            <div class="d-flex justify-content-between align-items-center mt-2">
                                <small class="text-muted fw-semibold">
                                     \${item.empNm}
                                </small>
                                <small class="text-muted">
                                    <span class="material-icons align-middle" style="font-size: 14px;">visibility</span> \${item.clubBbsCnt}
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            });

            container.innerHTML = str;
            document.getElementById("galleryPagingArea").innerHTML = articlePage.pagingArea || "";
        }


        //포토갤러리 검색
        const btnGallerySearch = document.getElementById("btnGallerySearch");
        if (btnGallerySearch) {
            btnGallerySearch.addEventListener("click", () => {
                const keyword = document.getElementById("gallerySearchKeyword").value || "";

                const data = {
                    "currentPage": 1,
                    "clubNo": 3,
                    "mode": "gallery",
                    "keyword": keyword
                };

                axios.post("/club/clubBoardListAxios", data, {
                    headers: {"Content-Type": "application/json;charset=utf-8"}
                })
                    .then(response => {
                        galleryListShowFn(response.data);
                    })
                    .catch(err => console.error("갤러리 검색 오류:", err));
            });
            document.getElementById("gallerySearchKeyword").addEventListener("keypress", function (event) {
                if (event.key === "Enter") {
                    event.preventDefault();
                    btnGallerySearch.click();
                }
            });
        }

        //갤러리 상세 보기
        function goToGalleryDetail(clubBbsNo) {
            axios.get(`/club/boardDetail?clubBbsNo=\${clubBbsNo}`)
                .then(response => {
                    const gallery = response.data;

                    const dateObj = new Date(gallery.clubBbsDt);
                    const formattedDate = dateObj.getFullYear() + '-' +
                        String(dateObj.getMonth() + 1).padStart(2, '0') + '-' +
                        String(dateObj.getDate()).padStart(2, '0');

                    const jbgd = gallery.empJbgd ? gallery.empJbgd : '사원';
                    const dept = gallery.deptNm ? gallery.deptNm : '소속없음';

                    let gAvatarTag = (gallery.avtSaveNm && gallery.avtSaveNm !== 'NONE')
                        ? `<img src="/avatar/displayAvt?fileName=\${gallery.avtSaveNm}" alt="Avatar" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover; margin-right: 10px; border: 1px solid #eee;">`
                        : `<span class="material-icons text-primary me-2" style="font-size: 48px;">account_circle</span>`;
                    document.getElementById('g-detail-writer').innerHTML = `\${gAvatarTag} [\${dept}] \${gallery.empNm}(\${jbgd})`;
                    document.getElementById('g-detail-title').innerText = gallery.clubBbsTtl;
                    document.getElementById('g-detail-date').innerText = formattedDate;
                    document.getElementById('g-detail-cnt').innerText = gallery.clubBbsCnt;
                    document.getElementById('g-detail-content').innerHTML = gallery.clubBbsCn || "설명이 없습니다.";

                    const fileList = gallery.fileList || [];
                    const indicators = document.getElementById('g-carousel-indicators');
                    const inner = document.getElementById('g-carousel-inner');

                    indicators.innerHTML = '';
                    inner.innerHTML = '';
                    if (fileList.length > 0) {
                        fileList.forEach((file, index) => {
                            const activeClass = index === 0 ? 'active' : '';

                            indicators.innerHTML += `<button type="button" data-bs-target="#galleryCarousel" data-bs-slide-to="\${index}" class="\${activeClass}"></button>`;

                            let imgSrc = `/upload\${file.fileDtlPath}`;
                            inner.innerHTML += `
                            <div class="carousel-item \${activeClass}" style="height: 450px;">
                                <img src="\${imgSrc}" class="d-block w-100 h-100" style="object-fit: contain;" alt="갤러리 이미지 \${index+1}">
                            </div>
                        `;
                        });
                        const btnDisplay = fileList.length === 1 ? 'none' : 'block';
                        document.getElementById('g-carousel-prev').style.display = btnDisplay;
                        document.getElementById('g-carousel-next').style.display = btnDisplay;
                    } else {
                        inner.innerHTML = `<div class="carousel-item active" style="height: 450px; display: flex; align-items: center; justify-content: center; color: white;">이미지가 없습니다.</div>`;
                        document.getElementById('g-carousel-prev').style.display = 'none';
                        document.getElementById('g-carousel-next').style.display = 'none';
                    }

                    const galleryDeleteBtn = document.getElementById('btn-delete-gallery');
                    if (galleryDeleteBtn) {
                        if (String(gallery.clubMbrNo) === String(myEmpId)) {
                            galleryDeleteBtn.style.display = 'inline-block';
                            galleryDeleteBtn.setAttribute('onclick', `deleteGallery(\${gallery.clubBbsNo})`);
                        } else {
                            galleryDeleteBtn.style.display = 'none';
                        }
                    }
                    document.getElementById('gallery-list-area').style.display = 'none';
                    document.getElementById('gallery-write-area').style.display = 'none';
                    document.getElementById('gallery-detail-area').style.display = 'block';
                })
                .catch(error => {
                    console.error("갤러리 상세 조회 에러:", error);
                    // (알람 리팩토링) 상세 조회 에러 알림
                    AppAlert.error('오류 발생', '상세 정보를 불러오는 중 오류가 발생했습니다.');
                });
        }

        // 포토 갤러리 목록 돌아가기
        function goToGalleryList() {
            document.getElementById('gallery-detail-area').style.display = 'none';
            document.getElementById('gallery-write-area').style.display = 'none';
            document.getElementById('gallery-list-area').style.display = 'block';

            loadGalleryList();
        }

        // 갤러리 사진 삭제 함수
        function deleteGallery(clubBbsNo) {
            // (알람 리팩토링) 갤러리 삭제 컨펌창
            AppAlert.confirm('사진을 삭제하시겠습니까?', '정말로 사진을 지우시겠습니까?', '삭제', '취소', 'delete', 'danger')
                .then((result) => {
                    if (result.isConfirmed) {
                        axios.post("/club/galleryDelete", clubBbsNo, {
                            headers: {"Content-Type": "application/json;charset=utf-8"}
                        })
                            .then(response => {
                                // (알람 리팩토링) 자동 닫힘 완료 알림
                                AppAlert.autoClose('삭제 완료', '사진이 삭제되었습니다.', 'check_circle', 'success')
                                    .then(() => {
                                        goToGalleryList();
                                    });
                            })
                            .catch(error => {
                                console.error("갤러리 삭제 에러:", error);
                                // (알람 리팩토링) 에러 알림
                                AppAlert.error('오류 발생', '삭제 중 오류가 발생했습니다.');
                            });
                    }
                });
        }


</script>