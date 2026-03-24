<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ include file="calendarHeader.jsp"%>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/themes/default/style.min.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/jstree/3.3.12/jstree.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
<!-- SweetAlert2 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


<div id="globalAlertContainer" style="position: fixed; top: 20px; right: 20px; z-index: 9999;"></div>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div style="color: #2c3e50; display: flex; align-items: center; gap: 10px;">
            <span class="material-icons" style="color: #696cff; font-size: 32px;">event_available</span>
            <div style="display: flex; align-items: baseline; gap: 8px;">
                <span style="font-size: x-large; font-weight: 800;">나의 업무 일정</span>
            </div>
        </div>
        <div style="font-size: 15px; color: #717171; margin-top: 8px; letter-spacing: -0.5px; font-weight: 400;">
            부서 일정 및 공유된 협업 일정을 확인하고 실시간으로 업무 스케줄을 조정을 위한 페이지입니다.
        </div>
    </div>
</div>


<!-- 캘린더 -->
<div class="container-xxl mt-4">
    <div class="row g-4">
        <div class="col-lg-11 col-md-9 col-12">
            <div class="card shadow-sm p-4" style="border: none !important; box-shadow: none !important; background-color:#f5f7fe;">

                <!-- [캘린더 하단 버튼 영역] -->
                <div class="d-flex justify-content-between align-items-center mt-3 pt-3">
                    <div id="bottomBtn" style="margin-top:-70px; margin-bottom:20px;">
                        <button type="button" class="write shadow-sm">
                            <span class="upload-icon" style="margin-bottom:0px;">+</span> 일정 추가
                        </button>
                        <button type="button" class="csize ms-2">크기 변경</button>
                    </div>
                </div>

                <!-- [캘린더 영역] -->
                <div id="calendar"></div>
            </div>
        </div>
        
        
		<!-- [오른쪽 메뉴 영역] -->
        <div class="col-lg-1 col-md-3 col-12">
            <!-- 일정 범례(Legend) 카드 추가 -->
                <div class="card shadow-sm mb-3" style="background: #fff; border-radius: 0.75rem; padding:10px; min-width: 220px; margin-top:20px;">
                    <div class="card-header bg-white py-3" style="display: flex; justify-content: center; align-items: center;">
                        <h5 class="mb-0 fw-bold">🎨 일정 색상</h5>
                    </div>
                    <div class="card-body" style="padding: 0px 5px 20px 20px;">
                        <div class="legend-list" style="display: flex; flex-direction: column; gap: 8px;">
                            <!-- 일반 일정 -->
                            <div class="legend-item" style="display: flex; align-items: center; margin-left:20px;">
                                <span class="dot" style="background-color: #8e91ff; width: 14px; height: 14px; border-radius: 50%; display: inline-block;"></span>
                                <span style="font-size: 14px; font-weight: 400; color: #495057; margin-left: 15px;">일반 일정</span>
                            </div>
                            <!-- 연차 -->
                            <div class="legend-item" style="display: flex; align-items: center; margin-left:20px;">
                                <span class="dot" style="background-color: #f5a4b7; width: 14px; height: 14px; border-radius: 50%; display: inline-block;"></span>
                                <span style="font-size: 14px; font-weight: 400; color: #495057; margin-left: 15px;">연차</span>
                            </div>
                            <!-- 출장 -->
                            <div class="legend-item" style="display: flex; align-items: center; margin-left:20px;">
                                <span class="dot" style="background-color: #fdc67e; width: 14px; height: 14px; border-radius: 50%; display: inline-block;"></span>
                                <span style="font-size: 14px; font-weight: 400; color: #495057; margin-left: 15px;">출장</span>
                            </div>
                            <!-- 프로젝트 -->
                            <div class="legend-item" style="display: flex; align-items: center; margin-left:20px;">
                                <span class="dot" style="background-color: #91d4a8; width: 14px; height: 14px; border-radius: 50%; display: inline-block;"></span>
                                <span style="font-size: 14px; font-weight: 400; color: #495057; margin-left: 15px;">프로젝트</span>
                            </div>
                            <!-- 회의실 예약 -->
                            <div class="legend-item" style="display: flex; align-items: center; margin-left:20px;">
                                <span class="dot" style="background-color: #a1adb9; width: 14px; height: 14px; border-radius: 50%; display: inline-block;"></span>
                                <span style="font-size: 14px; font-weight: 400; color: #495057; margin-left: 15px;">회의실 예약</span>
                            </div>
                        </div>
                    </div>
                </div>

            <div class="card shadow-sm mb-4"  style="background: #fff; border-radius: 0.75rem;  padding:10px; min-width: 220px; margin-top:-5px;">
                <div class="card-header bg-white py-3" style="display: flex; justify-content: center; align-items: center;">
                    <h5 class="mb-0 fw-bold" id="scheduleTitle" style="display: flex; align-items: center; gap: 8px;">
                        📅 내 일정
                        <span class="help-icon2" data-help="선택한 연차, 출장 일정이 달력에 표시됩니다." style="font-size: 0.9rem;">
                            <i class="fas fa-question-circle"></i>
                        </span>
                    </h5>
                </div>
                <div class="card-body" style="margin-top:-5px;">
                    <div class="form-check mb-2 d-flex align-items-center">
                        <input class="form-check-input me-2" type="checkbox" id="checkVacation" >
                        <label class="form-check-label" for="checkVacation">
                            <span class="dot" style="background-color: #f5a4b7;"></span>
                            <span>연차</span>
                            <span class="count-text" id="vctCount">(0/0/15)</span>
                            <span class="help-icon2" data-help="해당 월 연차 수 / 총 사용 연차 수 / 사용 가능한 총 연차 수">
                                <i class="fas fa-question-circle"></i>
                            </span>
                        </label>
                    </div>
                    <div class="form-check mb-2 d-flex align-items-center" style="margin-top:-5px;">
                        <input class="form-check-input me-2" type="checkbox" id="checkBizTrip" >
                        <label class="form-check-label" for="checkBizTrip">
                            <span class="dot" style="background-color: #fdc67e;"></span>
                            <span>출장</span>
                            <span class="count-text" id="bzCount">(0/0)</span>
                            <span class="help-icon2" data-help="해당 월 출장 횟수 / 총 출장 횟수">
                                <i class="fas fa-question-circle"></i>
                            </span>
                        </label>
                    </div>
                    <div class="card-footer bg-white border-top-0 pt-0">
                        <button type="button" class="allSelectBtn" onclick="allClick()" style="margin-bottom:-10px; margin-top:10px;">전체 선택</button>
                    </div>
                </div>
            </div>

            <!-- 부서 일정 보기 -->
            <sec:authorize access="hasRole('팀장')">
                <div class="card shadow-sm mb-4"  style="background: #fff; border-radius: 0.75rem; padding:10px; min-width: 220px; margin-top:-10px;">
                    <div class="card-header bg-white py-3 flex-column align-items-start">
                        <h5 class="mb-0 fw-bold"  style="padding-left:10px;">👥 부서 일정 보기
						    <span class="help-icon2" data-help="팀원 클릭 시 해당 인원의 일정과 선택한 연차, 출장 일정이 표시됩니다.">
		                   		<i class="fas fa-question-circle"></i>
		                    </span>
	                    </h5>
                        <small class="text-muted" style="font-size: 15px; padding-left:10px;">
                            <c:out value="${deptNm}" default="부서 없음" />
                        </small>
                    </div>
                    <div class="card-body">
                        <div class="member-list-scroll" style="max-height: 180px; overflow-y: auto; margin-top:-30px;">
                            <c:forEach var="emp" items="${teamList}" varStatus="stat" >
                                <div class="form-check mb-2 d-flex align-items-center member-item" style="margin-top:-10px;">
                                    <input class="form-check-input me-2 member-check" type="checkbox"
                                           value="${emp.empId}" id="check_${emp.empId}" onclick="checkOnlyOne(this)">
                                    <label class="form-check-label d-flex align-items-center w-100" for="check_${emp.empId}" >
                                            <c:out value="${emp.empNm}" /> <c:out value="${emp.empJbgd}" />
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                        <div class="card-footer bg-white border-top-0 pt-0">
                            <button type="button" class="myCalBtn" onclick="myCalendar()" style="margin-bottom:-10px; margin-top:10px;">내 일정</button>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>
    </div>
</div>


<!-- [일정 추가 입력 모달 창] -->
<div id="addSchedule" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(38, 43, 67, 0.5); backdrop-filter: blur(4px);">    

    <input type="hidden" id="calNo" /> 
    <input type="hidden" id="empId" />
    <input type="hidden" id="loginId" value="${loginId}">
    
    <div class="modal-card" style="background-color: white; margin: 5% auto; width: 450px; border-radius: 0.75rem; overflow: hidden; display: flex; flex-direction: column;">
       <div class="modal-header" style="background: #f5f5f9; padding: 20px; border-bottom: 1px solid #d9dee3;">
           <h4 style="margin: 0; color: #566a7f; font-weight: 700;">📅 일정 상세 설정</h4>
       </div>

	   <div id="globalAlertContainer" style="position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;"></div>

       <div style="padding: 25px; max-height: 70vh; overflow-y: auto;">
           <form id="scheduleForm" enctype="multipart/form-data">
			    <div class="important-container">
				    <input type="checkbox" id="importantBtn" name="isImportant">

				    <label for="importantBtn" class="star-toggle"></label>

				    <label for="importantBtn" class="important-label">
				        중요한 일정
				    </label>
                    <span class="help-icon" data-help="중요한 일정을 설정하면 제일 위쪽으로 일정이 배치됩니다."><i class="fas fa-question-circle"></i></span>
				</div>

               <div class="mb-3">
                   <label class="fw-bold mb-1">일정 제목</label>
                   <span class="help-icon" data-help="달력에 표시될 핵심 제목을 입력하세요.">
                   		<i class="fas fa-question-circle"></i>
                   </span>
                    <button type="button" id="autoFillBtn"
                       style="background-color: #ffffff; color: #64748b; border: 1px solid #e2e8f0; padding: 5px 7px; border-radius: 5px; cursor: pointer; font-weight: 500; font-size: 0.6rem; margin-left:10px; margin-bottom:5px;">
                       자동 입력
                   </button>
                   <input type="text" id="title" name="title" class="form-control" placeholder="제목을 입력하세요">
               </div>

               <div class="mb-3">
                   <label class="fw-bold mb-1">📍 장소</label>
                   <input type="text" id="location" name="location" class="form-control" placeholder="장소를 입력하세요">
               </div>

            <div class="mb-3">
		        <label class="fw-bold mb-1">시작 일시</label>
		        <div class="datetime-group">
		            <div class="datetime-item">
		                <input type="date" id="startDate" class="form-control">
		            </div>
		            <div class="datetime-item">
		                <select id="startTime" class="form-select">
		                    <option value="" selected>시간 선택</option>
		                    <c:forEach var="h" begin="9" end="18">
		                        <option value="${h < 10 ? '0' : ''}${h}:00">${h < 10 ? '0' : ''}${h}:00</option>
		                    </c:forEach>
		                </select>
		            </div>
		        </div>
		    </div>
		
		    <div class="mb-4">
		        <label class="fw-bold mb-1">종료 일시</label>
		        <div class="datetime-group">
		            <div class="datetime-item">
		                <input type="date" id="endDate" class="form-control">
		            </div>
		            <div class="datetime-item">
		                <select id="endTime" class="form-select">
		                    <option value="">시간 선택</option>
		                    <c:forEach var="h" begin="9" end="18">
		                        <option value="${h < 10 ? '0' : ''}${h}:00">${h < 10 ? '0' : ''}${h}:00</option>
		                    </c:forEach>
		                </select>
		            </div>
		        </div>
		    </div>

            <div class="mb-4">
		        <label class="fw-bold mb-1">👥 일정 공유</label>
		        <span class="help-icon" data-help="개인, 부서별 또는 전체 직원을 선택하여 일정을 공유할 수 있습니다."><i class="fas fa-question-circle"></i></span>
		        <div class="select-wrapper">
		            <button type="button" id="share">공유 대상 선택</button>
		        </div>
				
				<!-- 공유 대상 목록 -->
				<div id="sharedUserWrapper" style="display: none;" class="mt-2">
				    <label class="small fw-bold text-muted">선택된 공유 대상:</label>
				    <div id="sharedUserDisplayContainer" class="form-control form-control-sm d-flex flex-wrap gap-2 align-items-center" 
				         style="background-color: #f8f9fa; border-radius: 8px; min-height: 30px; height: auto; padding:7px; padding-bottom:-10px;">
				        
				        <input type="hidden" id="sharedUserIds" name="sharedUserIds" value="">
				    </div>
				
				    <div class="text-end mt-1">
				        <button type="button" id="allDeleteBtn" class="btn btn-link btn-sm text-danger text-decoration-none p-0" onclick="clearShare()">
				            전체 삭제
				        </button>
				    </div>
				</div>
			</div>
						    

            <div class="mb-3">
                 <label class="fw-bold mb-1">상세 내용</label>
                 <textarea id="content" name="content" rows="3" class="form-control" placeholder="내용을 입력하세요"></textarea>
             </div>


            <div class="mb-3"  style="margin-top:10px;">
		        <label class="fw-bold mb-1">첨부 파일</label>
		        <span class="help-icon" data-help="관련 문서나 이미지 파일을 최대 5개까지 업로드할 수 있습니다."><i class="fas fa-question-circle"></i></span>
		        <div class="file-upload-wrapper">
		            <input type="file" id="calendarFile" name="calendarFile" multiple style="display: none;">
		            <label for="calendarFile" class="file-upload-btn">
		               <%-- <span class="upload-icon">📁</span>--%>
		                <span id="fileNameDisplay" class="upload-icon" style="text-align: center;">📁<br>클릭하여 첨부파일을 업로드하세요</span>
	                	<!-- [이미지 미리보기] -->
	    				<div id="FilePreview"></div>
		            </label>
		        </div>
		    </div>
			</form>
         </div>
            <div class="modal-footer" style="padding: 20px; background: #f5f5f9; border-top: 1px solid #d9dee3; display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" id="closeBtn">닫기</button>
                <button type="button" id="deleteBtn" style="background-color: #435971; color: white;">삭제</button>
                <button type="button" id="saveBtn">저장</button>
                <button type="button" id="updateBtn">수정</button>
            </div>
    </div>
</div>



<!-- ---------------[조직도 모달]------------- -->
<div id="orgChartModal" style="display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); backdrop-filter: blur(2px);">
    <div class="modal-card" style="background: white; margin: 8% auto; width: 450px; border-radius: 12px; padding: 25px; box-shadow: 0 10px 30px rgba(0,0,0,0.3);">
        <div class="modal-header d-flex justify-content-between align-items-center mb-4">
            <button type="button" class="btn-close" id="closeOrgModal" style="border:none; background:none; font-size:20px; cursor:pointer;">&times;</button>
            <h5 class="fw-bold mb-0">👥 공유 범위 선택</h5>
        </div>
        
        <div class="share-tab-container mb-4">
		    <div class="share-tab-group">
		        <input type="radio" name="shareType" id="typeIndividual" class="share-input" checked>
		        <label class="share-label" for="typeIndividual">
		            <i class="fas fa-user me-1"></i> 개인
		        </label>
		
		        <input type="radio" name="shareType" id="typeDept" class="share-input">
		        <label class="share-label" for="typeDept">
		            <i class="fas fa-users me-1"></i> 부서
		        </label>
		
		        <input type="radio" name="shareType" id="typeAll" class="share-input">
		        <label class="share-label" for="typeAll">
		            <i class="fas fa-globe me-1"></i> 전체
		        </label>
		        
		        <div class="tab-slider"></div>
		    </div>
		</div>

        <div class="modal-body border rounded p-3" style="min-height: 300px; background: #fcfcfd;">
            <div id="treeArea"  style="padding-top:15px;" >
                <div id="jstree_div" style="max-height: 350px; overflow-y: auto;"></div>
            </div>
            <div id="deptArea" style="display:none; padding-top:15px; padding-left:20px;">
                <div id="deptListGroup" class="list-group" style="max-height: 300px; overflow-y: auto;"></div>
            </div>
            <div id="allArea" style="display:none;">
			    <div class="list-group">
		            <div class="ms-1" style="padding-top:15px; padding-left:20px;">
			        	<label class="list-group-item d-flex align-items-center gap-2 cursor-pointer border-0 py-3" 
			               		style="margin-left:-10px; transition: all 0.2s;">
			            <input class="form-check-input" type="checkbox" id="allCheck" 
			                   value="ALL" data-name="전체" style="margin: 0; width: 1.2rem; height: 1.2rem;">
			            <i class="fas fa-globe ms-1" style="width: 20px; text-align: center; font-size: 1.1rem; color: #8e91ff;"></i> 
		                <span class="fw-bold" style="font-size: 14px; color: #566a7f;">전체</span>
			        	</label>
		            </div>
			    </div>
			</div>
        </div>

        <div class="modal-footer mt-4 d-flex justify-content-end gap-2">
            <button type="button" id="confirmShare" class="btn btn-primary px-4">선택 완료</button>
        </div>
    </div>
</div>



<!-- 통합 일정 상세 모달 -->
<div id="anotherDetailModal" class="modal" style="display:none; position: fixed; z-index: 1050; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 480px; margin: 1.75rem auto;">
        <div class="modal-content" style="border: none; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.15); overflow: hidden;">
            <div id="modalThemeBar" style="height: 8px; background: #696cff;"></div>
            <div class="modal-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid #f0f2f4; align-items: center;">
                <h5 class="modal-title fw-bold" id="modalTypeTitle" style="color: #333; letter-spacing: -0.5px;">📅 일정 상세 정보</h5>
                <button type="button" class="btn-close" onclick="closeAnotherModal()" style="border:none; background:none; font-size:1.4rem; cursor:pointer; outline: none; box-shadow: none; color: #aaa;">&times;</button>
            </div>
            <div class="modal-body" style="padding: 1.5rem;">
                <div style="display: none;"><span id="p_no"></span></div>
                <!-- 제목 섹션 -->
                <div class="mb-4">
                    <label class="form-label d-flex align-items-center fw-bold text-muted small mb-2">
                        <i class="fas fa-thumbtack me-2"></i> 제목
                    </label>
                    <div id="p_title" style="font-size: 1.25rem; font-weight: 700; color: #2c3e50; line-height: 1.4; word-break: break-all;"></div>
                </div>
                <!-- 기간 섹션 -->
                <div class="mb-4">
                    <label class="form-label d-flex align-items-center fw-bold text-muted small mb-2">
                        <i class="fas fa-calendar-alt me-2"></i> 기간
                    </label>
                    <div class="d-flex align-items-center p-3" style="background-color: #f8f9fa; border-radius: 10px; border: 1px solid #edf0f2;">
                        <div class="text-center" style="flex: 1;">
                            <div class="text-muted mb-1" style="font-size: 0.75rem; text-transform: uppercase;">시작일</div>
                            <div id="p_startDate" style="font-weight: 600; color: #444; font-size: 0.95rem;"></div>
                        </div>
                        <div class="text-center" style="flex: 1;">
                            <div class="text-muted mb-1" style="font-size: 0.75rem; text-transform: uppercase;">종료일</div>
                            <div id="p_endDate" style="font-weight: 600; color: #444; font-size: 0.95rem;"></div>
                        </div>
                    </div>
                </div>
            </div>
            <button type="button" class="btn" onclick="goToListView()" id="anotherListViewBtn"
                    style="min-width: 140px; height: 45px; color: #ffffff; font-weight: 700; font-size: 0.95rem; transition: all 0.2s; box-shadow: 0 4px 8px rgba(105, 108, 255, 0.25); display: flex; align-items: center; justify-content: center; gap: 6px;">
                <span class="material-icons" style="font-size: 1.2rem;">list_alt</span>
                신청 내역 보기
            </button>
        </div>
    </div>
</div>



<script type="text/javascript">

let calendar;
let currentSelectedEmpId = "";

// [내 일정] 버튼 클릭  ----------------------------------------------------------------------
function myCalendar() {
    // 1. 부서원 체크박스 전체 해제
    const checkboxes = document.querySelectorAll('.member-check');
    checkboxes.forEach(cb => cb.checked = false);

    // 2. 연차/출장 체크박스 해제
    const vacCk = document.getElementById('checkVacation');
    const bizCk = document.getElementById('checkBizTrip');
    if (vacCk) vacCk.checked = false;
    if (bizCk) bizCk.checked = false;

    // 3. 달력에 표시된 연차/출장 데이터 제거
    if (calendar) {
        const vacSource = calendar.getEventSourceById('vacSource');
        const bizSource = calendar.getEventSourceById('bizSource');
        if (vacSource) vacSource.remove();
        if (bizSource) bizSource.remove();
    }

    // 4. 제목 복구 및 사번 변수 초기화
    const scheduleTitle = document.getElementById('scheduleTitle');
    if (scheduleTitle) scheduleTitle.innerText = "📅 내 일정";
    currentSelectedEmpId = "";

    // 5. 일정 추가 버튼 보이기
    const writeBtn = document.querySelector("#bottomBtn .write");
    if(writeBtn) writeBtn.style.display = 'inline-block';

    // 6. 일반 일정 리프레시
    calendar.refetchEvents();
}


// [alert] ------------------------------------------------------------
window.showAlert = function(message, type = 'success') {
    const iconMap = {
        'success': 'check_circle',
        'danger': 'error_outline',
        'error': 'error_outline',
        'warning': 'warning_amber',
        'info': 'info'
    };
    const icon = iconMap[type] || 'notifications';
    const theme = (type === 'danger' || type === 'error') ? 'error' : type;

    AppAlert.autoClose('알림', message, icon, theme, 2000);
};
/*
window.showAlert = function(message, type = 'warning') {
    let container = document.getElementById('globalAlertContainer');
    
    if (!container) {
        container = document.createElement('div');
        container.id = 'globalAlertContainer';
        container.style.cssText = "position: fixed; top: 20px; right: 20px; z-index: 9999;";
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `custom-toast ${type}`;
    
    const icons = { 
        success: 'fa-check-circle', 
        warning: 'fa-exclamation-triangle', 
        danger: 'fa-trash-alt' 
    };

    toast.innerHTML = `
        <i class="fas \${icons[type]} toast-icon"></i>
        <div class="toast-message">\${message}</div>
        <i class="fas fa-times toast-close" style="cursor:pointer; margin-left:10px;"></i>
    `;

    container.appendChild(toast);

    const closeToast = (el) => {
        el.style.opacity = '0';
        el.style.transform = 'translateX(30px)';
        el.style.transition = 'all 0.2s ease';
        setTimeout(() => { if (el.parentNode) el.remove(); }, 200);
    };

    setTimeout(() => closeToast(toast), 2500);
    toast.querySelector('.toast-close').onclick = () => closeToast(toast);
};
------------------------------------------------------------------
이미지 삽입
window.showAlert = function(message, type = 'success') {
    const container = document.getElementById('globalAlertContainer');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `custom-toast ${type}`;
    
    // 이미지 경로 설정
    const successImg = '../images/success_alert.png'; 
    const falseImg = '../images/false_alert.png'; 
    
    // 타입에 따른 이미지 선택
    let alertImg = (type === 'success') ? successImg : falseImg;

    toast.innerHTML = `
        <div class="toast-content" style="display: flex; align-items: center; width: 100%;">
            <img src="\${alertImg}" alt="\${type}" style="width: 45px; height: auto; margin-right: 15px;">
            <div class="toast-message" style="flex-grow: 1; font-size: 14px; font-weight: 600; color: #566a7f;">
                \${message}
            </div>
            <i class="fas fa-times toast-close" style="cursor: pointer; opacity: 0.5; margin-left: 10px;"></i>
        </div>
    `;

    container.appendChild(toast);

    const closeToast = (el) => {
        el.style.opacity = '0';
        el.style.transform = 'translateX(20px)';
        el.style.transition = 'all 0.25s ease';
        setTimeout(() => { if (el.parentNode) el.remove(); }, 250);
    };

    const timer = setTimeout(() => closeToast(toast), 3000);

    toast.querySelector('.toast-close').onclick = () => {
        clearTimeout(timer);
        closeToast(toast);
    };
};
*/



// 부서 일정 보기 체크박스 선택 제한
function checkOnlyOne(element) {
    const checkboxes = document.getElementsByClassName('member-check');
    const writeBtn = document.querySelector("#bottomBtn .write");

    // 1. 팀원 단일 선택 로직 (다른 팀원 체크 해제)
    Array.from(checkboxes).forEach((cb) => {
        if (cb !== element) cb.checked = false;
    });
    
    const scheduleTitle = document.getElementById('scheduleTitle');
    const vacCk = document.getElementById('checkVacation'); // 연차 체크박스
    const bizCk = document.getElementById('checkBizTrip');  // 출장 체크박스

    // 2. 부서원 변경 시 연차/출장 체크박스 무조건 해제
    if (vacCk) vacCk.checked = false;
    if (bizCk) bizCk.checked = false;

    // 3. 달력에서 기존에 로드된 연차/출장 데이터 소스 제거
    if (calendar) {
        const vacSource = calendar.getEventSourceById('vacSource');
        const bizSource = calendar.getEventSourceById('bizSource');
        if (vacSource) vacSource.remove();
        if (bizSource) bizSource.remove();
    }

    if (element.checked) {
        // 팀원 선택 시
        const empName = element.nextElementSibling.innerText.trim();
        scheduleTitle.innerText = `📅 \${empName}님의 일정`;
        currentSelectedEmpId = element.value; // 선택된 사번 저장
        if(writeBtn) writeBtn.style.display = 'none';   // 일정 추가 버튼 숨기기
    } else {
        scheduleTitle.innerText = `📅 내 일정`;
        currentSelectedEmpId = "";
        if(writeBtn) writeBtn.style.display = '';   // 버튼 다시 보이기
    }

    // 4. 기본 일정
    if (calendar) {
        calendar.refetchEvents();
    }
}


// [전체 선택 버튼 로직]
function allClick() {
    // 대상 체크박스들 가져오기
    const vctChk = document.getElementById('checkVacation');
    const bzChk = document.getElementById('checkBizTrip');

    // 현재 상태 확인
    const isBothChecked = vctChk.checked && bzChk.checked;

    if (isBothChecked) {
        // 둘 다 체크되어 있다면
        vctChk.checked = false;
        bzChk.checked = false;
    } else {
        // 하나라도 비어있다면
        vctChk.checked = true;
        bzChk.checked = true;
    }

    vctChk.dispatchEvent(new Event('change'));
    bzChk.dispatchEvent(new Event('change'));

    const btn = document.querySelector(".allSelectBtn");
    btn.innerText = vctChk.checked ? "전체 해제" : "전체 선택";
}





document.addEventListener('DOMContentLoaded', function() {
    const calendarEl = document.getElementById('calendar');
    const modal = document.getElementById('addSchedule');
    const scheduleForm = document.getElementById('scheduleForm');

    // [함수 정의 - 모달 모드 설정 (등록/수정)] ---------------------------------------------------------
    function setModalMode(mode, scheduleEmpId = "") {
        const btnSave = document.querySelector("#saveBtn");
        const btnUpdate = document.querySelector("#updateBtn");
        const btnDelete = document.querySelector("#deleteBtn");
        const btnAutoFill = document.querySelector("#autoFillBtn");
        const wrapper = document.getElementById('sharedUserWrapper');
        const filePreview = document.getElementById("FilePreview");

        if (mode === 'insert') {
            btnSave.style.display = 'inline-block';
            if (btnAutoFill) btnAutoFill.style.display = 'inline-block';
            btnUpdate.style.display = 'none';
            btnDelete.style.display = 'none';
            
            // 폼 초기화
            scheduleForm.reset(); 
            
            if(wrapper) wrapper.style.display = 'none';
            
            if (filePreview) {
                filePreview.innerHTML = "";
                document.getElementById('fileNameDisplay').textContent = "📁 클릭하여 첨부파일을 업로드하세요";
            }
            
        } else if (mode === 'edit') {
            const isOthersSchedule = (currentSelectedEmpId !== "") || (scheduleEmpId !== "" && scheduleEmpId !== loginId);

            if (isOthersSchedule) {
                // 조회 모드
                btnSave.style.display = 'none';
                btnUpdate.style.display = 'none';
                btnDelete.style.display = 'none';
                if (btnAutoFill) btnAutoFill.style.display = 'none';

            } else {
                // 내 일정 수정 모드
                btnSave.style.display = 'none';
                btnUpdate.style.display = 'inline-block';
                btnDelete.style.display = 'inline-block';
                if (btnAutoFill) btnAutoFill.style.display = 'none';
            }
        }
    }


    
 // [alert] ------------------------------------------------------------
 /*
    function showAlert(message, type = 'warning') {
    	const container = document.getElementById('globalAlertContainer');
        if (!container) return;

        const toast = document.createElement('div');
        toast.className = `custom-toast ${type}`;
        
        const icons = { 
            success: 'fa-check-circle', 
            warning: 'fa-exclamation-triangle', 
            danger: 'fa-trash-alt' 
        };

        toast.innerHTML = `
            <i class="fas \${icons[type]} toast-icon"></i>
            <div class="toast-message">\${message}</div>
            <i class="fas fa-times toast-close"></i>
        `;

        container.appendChild(toast);

        // 자동 삭제 타이머
        const autoCloseTimer = setTimeout(() => {
            closeToast(toast);
        }, 2500);

        // X 버튼 클릭 시 즉시 삭제
        toast.querySelector('.toast-close').onclick = function() {
            clearTimeout(autoCloseTimer);
            closeToast(toast);
        };

        // 내부 삭제 함수
        function closeToast(el) {
            if (!el) return;
            el.style.opacity = '0';
            el.style.transform = 'translateX(30px)';
            el.style.transition = 'all 0.2s ease';
            
            // 애니메이션 시간 끝난 후 DOM에서 완전히 삭제
            setTimeout(() => {
                if (el.parentNode) {
                    el.parentNode.removeChild(el);
                }
            }, 200);
        }
    }
    */

    
    
    // [공유 대상 선택시 보여지는 영역] ---------------------------------------------------------
    function shareUser(userList) {
    	const container = document.querySelector("#sharedUserDisplayContainer");
        const hiddenInput = document.querySelector("#sharedUserIds");
        
        container.innerHTML = "";
        let ids = [];

        userList.forEach(user => {
            ids.push(user.id);
            
            // 배지 생성
            const badge = document.createElement("div");
            badge.className = "user-badge";
            badge.innerHTML = `
                <span>${user.name}</span>
                <span class="remove-user" onclick="removeUser('${user.id}')">&times;</span>
            `;
            container.appendChild(badge);
        });

        hiddenInput.value = selectedValues.join(" ");
    }

    
    // [일정 공유 개별 삭제 함수] ---------------------------------------------------------
    function removeUser(userId) {
        let ids = document.querySelector("#sharedUserIds").value.split(",");
        ids = ids.filter(id => id !== userId);
        document.querySelector("#sharedUserIds").value = ids.join(",");
    }
    
    
    
    // [캘린더 초기화] ---------------------------------------------------------
    calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        locale: 'ko',
        displayEventTime: true,
        eventTimeFormat: {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        },
        headerToolbar: {
            left: 'prev,next today',
            center: 'title',
            right: 'dayGridMonth,dayGridWeek,timeGridDay'
        },
        contentHeight: 700,
        selectable: true,
        editable: true,
        droppable: true,
        displayEventTime: false,

        // DAY 시간 설정
        slotMinTime: '09:00:00',
        scrollTime: '09:00:00',

        
        // 중요 일정 우선 정렬
        eventOrder: "-important, -allDay, start",

        // 프로젝트 일정 제일 마지막으로 정렬
        eventOrder: "isProjectOrder,-important,start,title",
        
        // [통합된 데이터 불러오기] ---------------------------------------------------------
        events: function(info, successCallback, failureCallback) {
            const url = currentSelectedEmpId ? `/calendar/list?empId=\${currentSelectedEmpId}` : "/calendar/list";
            const loginId = document.querySelector("#loginId").value;
            
            axios.get(url)
                .then(response => {
                    const events = response.data.map(vo => {
                        const isHoliday = (vo.calHolidayYn === 'Y');

                        let finalColor = vo.calColor || '#8e91ff'; // 기본 색상

                     	// 팀원 색상
                        if (currentSelectedEmpId && vo.empId !== loginId && !isHoliday) {
                            finalColor = '#3788d8'; 
                        }

                        // 시간 포맷 정밀화
                        const formatTime = (timeStr) => {
                            if(!timeStr) return "";
                            return timeStr.includes(" ") ? timeStr.split(" ")[1] : timeStr;
                        };

                        const startTime = formatTime(vo.calBgngTm);
                        const endTime = formatTime(vo.calEndTm);

                        // 프로젝트 일정을 제일 밑에 순서로 배치
                        const isProject = (vo.isReservation === 'P');
                        const sortWeight = isProject ? 999 : 0;
                        const importantVal = (vo.calImportant === 'Y') ? 1 : 0;

                        return {
                            id: vo.calNo,
                            title: vo.calTtl,
                            start: vo.calBgngDt + (startTime ? 'T' + startTime : ''),
                            end: vo.calEndDt + (endTime ? 'T' + endTime : ''),
                            isProjectOrder: sortWeight,
                            important: importantVal,
                            color: vo.calColor,
                            display: isHoliday ? 'block' : 'auto',
                            backgroundColor: isHoliday ? 'transparent' : finalColor,
                            borderColor: isHoliday ? 'transparent' : (vo.calColor || '#8e91ff'),
                            allDay: vo.calAllday === 'Y',

                            extendedProps: {
                                important: importantVal,
                                isProjectOrder: sortWeight,
                                shareYn: vo.calShare || 'N',
                                content: vo.calCn,
                                location: vo.calLocation,
                                calDt : vo.calDt,
                                isHoliday: isHoliday ? 'Y' : 'N',
                                isReservation: vo.isReservation || 'N',
                                // [프로젝트]
                                projPrgrt: vo.projPrgrt,    // 진행률
                                projIpt: vo.projIpt,        // 프로젝트 중요도
                                projStts: vo.projStts,       // 참여자 명단
                                isProjectOrder: sortWeight
                            }
                        };
                    });

                    successCallback(events);
                })
                .catch(err => {
                    console.error("데이터 로딩 실패:", err);
                    failureCallback(err);
                });
        },


	    
        // [일정을 클릭했을 때 (수정 모드)] ----------------------------------------
        eventClick: function(info) {
            setModalMode('edit'); // 수정 모드로 버튼 변경
            document.getElementById('title').value = info.event.title;
            modal.style.display = 'block';
            
            const container = document.getElementById('globalAlertContainer');
            if (container) container.innerHTML = ""; 

            setModalMode("edit");
            
        },
        
        // [날짜 빈칸을 클릭했을 때 모달] -----------------------------
        select: function(info) {
            // 부서원 일정
            if (currentSelectedEmpId && currentSelectedEmpId !== "") {
                calendar.unselect();
                return;
            }

            // 내 일정
            setModalMode('insert');
            document.getElementById('startDate').value = info.startStr;

            // 종료일 -1
            let endDate = new Date(info.end);

            if (info.allDay) {
                endDate.setDate(endDate.getDate() - 1);
            }

            const year = endDate.getFullYear();
            const month = String(endDate.getMonth() + 1).padStart(2, '0');
            const day = String(endDate.getDate()).padStart(2, '0');
            const formattedEndDate = `\${year}-\${month}-\${day}`;

            document.getElementById('endDate').value = formattedEndDate;
            modal.style.display = 'block';
        },
        
     	// [일정 드래그 앤 드롭 시 (일정 수정)] ----------------------------------------
        editable: true, 
        droppable: true,
        
        eventDrop:function(info) {  // info : 드래그 앤 드롭 이벤트 객체

            // 부서원 일정
            if (currentSelectedEmpId && currentSelectedEmpId !== "") {
                info.revert(); // 원래 위치로 되돌리기
                return;
            }

        	AppAlert.confirm('일정 이동', '일정을 이 날짜로 이동하시겠습니까?', '이동하기', '취소', 'event_repeat', 'primary')
            .then((result) => {
                if (result.isConfirmed) {
                    let event = info.event;
                    let updateData = {
                        "calNo": event.id,
                        "calBgngDt": event.startStr.split('T')[0],
                        "calEndDt": event.end ? event.endStr.split('T')[0] : event.startStr.split('T')[0]
                    };

                    axios.patch("/calendar/updateRange", updateData, {
                        headers: { "Content-Type": "application/json;charset=utf-8" }
                    })
                    .then(response => {
                        window.showAlert('일정 날짜가 변경되었습니다.', 'success');
                    })
                    .catch(err => {
                        console.error("err : ", err);
                        window.showAlert('날짜 변경 중 오류가 발생했습니다.', 'danger');
                        info.revert();
                    });
                } else {
                    info.revert();
                }
            });
        },
        
        
        datesSet: function(info) {
            calendar.refetchEvents(); 
        },


        // [FullCalendar 스타일 및 아이콘 제어] ---------------------------------------------------------
        eventDidMount: function(info) {
		    const { event, el } = info;
            const props = event.extendedProps;

            // 공휴일
            if (props.isHoliday === 'Y') {
                el.style.setProperty('display', 'none', 'important');
                const dayCell = el.closest('.fc-daygrid-day');
                if (dayCell) {
                    const topArea = dayCell.querySelector('.fc-daygrid-day-top');
                    if (topArea) {
                        const dayNumber = topArea.querySelector('.fc-daygrid-day-number');
                        if (dayNumber) dayNumber.style.color = '#ff3e1d';
                        if (!topArea.querySelector('.holiday-text-top')) {
                            const span = document.createElement('span');
                            span.className = 'holiday-text-top';
                            span.innerText = event.title;
                            topArea.appendChild(span);
                        }
                    }
                }
                return;
            }

            // 프로젝트
            if (props.isReservation === 'P') {
                const baseProjColor = '#43a047';

                el.style.border = 'none';
                el.style.paddingLeft = '5px';
                el.style.marginBottom = '2px';
                el.style.borderRadius = '4px';
                el.style.setProperty('background-color', baseProjColor + '22', 'important');
                el.style.setProperty('border-left', `5px solid \${baseProjColor}`, 'important');

                const titleEl = el.querySelector('.fc-event-title');
                if (titleEl) {
                    titleEl.style.setProperty('color', baseProjColor, 'important');
                    titleEl.style.setProperty('font-weight', '500', 'important');
                }
                return;
            }


            let originColor = (event.backgroundColor || '#8e91ff').toLowerCase();
            let baseColor = originColor;

            if (originColor === '#f2a3b3' || originColor === '#f5a4b7') {
                baseColor = '#de788d'; // 연차
            } else if (originColor === '#ffab00' || originColor === '#fdc67e') {
                baseColor = '#ffab00'; // 출장
            } else if (originColor === '#8e91ff') {
                baseColor = '#696cff'; // 일반
            }

            // 엘리먼트 스타일
            el.style.border = 'none'; // 기본 테두리 제거
            el.style.paddingLeft = '5px'; // 왼쪽 바 공간
            el.style.marginBottom = '2px'; // 일정 간 간격
            el.style.borderRadius = '4px'; // 둥근 모서리
            el.style.setProperty('background-color', baseColor + '22', 'important');
            el.style.setProperty('border-left', `4px solid \${baseColor}`, 'important');

            // 글자색
            const titleEl = el.querySelector('.fc-event-title');
            if (titleEl) {
                titleEl.style.setProperty('color', baseColor, 'important');
                titleEl.style.setProperty('font-weight', '500', 'important');
                titleEl.style.setProperty('font-size', '1.1em', 'important');
            }

            // 회의실 예약
            if (props.isReservation === 'Y') {
                const fixedColor = '#566a7f';

                el.style.paddingLeft = '5px';
                el.style.marginBottom = '2px';
                el.style.borderRadius = '4px';
                el.style.border = 'none';
                el.style.setProperty('background-color', fixedColor + '22', 'important');
                el.style.setProperty('border-left', `4px solid \${fixedColor}`, 'important');

                const titleEl = el.querySelector('.fc-event-title');
                const timeEl = el.querySelector('.fc-event-time');

                if (titleEl) {
                    titleEl.style.setProperty('color', fixedColor, 'important');
                    titleEl.style.setProperty('font-weight', '500', 'important');
                    titleEl.style.setProperty('font-size', '1.1em', 'important');
                }

                if (timeEl) {
                    timeEl.style.setProperty('color', fixedColor, 'important');
                }
                return;
            }


            // 중요 일정 스타일 (왼쪽 띠)
            if (props.important === 'Y'|| props.important === 1) {
                const loginId = document.querySelector("#loginId").value;
                const isOthers = currentSelectedEmpId && currentSelectedEmpId !== "" ;

                // 부서원 일정이면 파란색, 내 일정이면 원래 보라색(#8e91ff) 사용
                const accentColor = isOthers ? '#3788d8' : '#8e91ff';
                const borderColor = isOthers ? '#3788d8' : (baseColor || '#8e91ff');

                el.style.borderLeft = `6px solid \${accentColor}`;
                el.style.setProperty('border', `1px solid \${borderColor}`, 'important');
                el.style.setProperty('border-left', `6px solid \${accentColor}`, 'important');
            }

		},
        
        
     	// [일정 클릭 시 실행] ---------------------------------------------------------
        eventClick: function(info) {
            const id = info.event.id;
            const props = info.event.extendedProps;
            const eventSourceId = info.event.source ? info.event.source.id : '';

            console.log("클릭한 일정 ID: ", id, " / 소스 ID: ", eventSourceId);
            console.log("연차 사유 데이터:", props.vctDocRsn);

            // 1. 연차 또는 출장
            if (eventSourceId === 'vacSource' || eventSourceId === 'bizSource') {
                const isVac = (eventSourceId === 'vacSource');
                const reason = isVac ? props.vctDocRsn : (props.bztrpRsn || props.vctDocRsn);

                openAnotherModal(isVac ? 'vacation' : 'bizTrip', {
                    id: id,
                    title: info.event.title,
                    start: info.event.startStr.split('T')[0],
                    end: info.event.endStr ? info.event.endStr.split('T')[0] : info.event.startStr.split('T')[0],
                });
                return;
            }

            // 2. 프로젝트 일정
            if (props.isReservation === 'P') {
                openAnotherModal('project', {
                    id: info.event.id,
                    title: info.event.title,
                    start: info.event.startStr.split('T')[0],
                    end: info.event.endStr ? info.event.endStr.split('T')[0] : '',
                    status: props.projStts || '진행중'
                });
                return;
            }

            // 3. 회의실 예약
            if (props.type === 'ROOM' || props.isReservation === 'Y') {

                const formatDateTime = (str) => {
                    if (!str) return '-';
                    return str.replace('T', ' ').split('+')[0];
                };

                openAnotherModal('reservation', {
                    id: id,
                    title: info.event.title,
                    start: info.event.startStr.replace('T', ' '),
                    end: info.event.endStr ? info.event.endStr.replace('T', ' ') : '',
                });
                return;
            }

            // --- [STEP 2] 일반 일정인 경우: 서버에서 상세 데이터 로드 ---
            setModalMode("edit");

            axios.get("/calendar/detail?id=" + id)
                .then(response => {
                    const data = response.data;
                    if (!data) return;

                    // 기본 필드 채우기
                    document.querySelector("#calNo").value = data.calNo;
                    document.querySelector("#empId").value = data.empId || '';
                    document.querySelector("#title").value = data.calTtl || '';
                    document.querySelector("#content").value = data.calCn || '';
                    document.querySelector("#location").value = data.calLocation || '';
                    document.querySelector("#startDate").value = data.calBgngDt || '';
                    document.querySelector("#endDate").value = data.calEndDt || '';

                    // 시간 처리 함수
                    const formatTime = (timeStr) => {
                        if(!timeStr) return "";
                        return timeStr.includes(' ') ? timeStr.split(' ')[1].substring(0, 5) : timeStr.substring(0, 5);
                    };
                    document.querySelector("#startTime").value = formatTime(data.calBgngTm);
                    document.querySelector("#endTime").value = formatTime(data.calEndTm);

                    // 중요 일정 체크박스
                    const importantBtn = document.querySelector("#importantBtn");
                    importantBtn.checked = (data.calImportant === 'Y');
                    importantBtn.value = data.calImportant;

                    // 공유 대상 배지 출력
                    const shares = data.calendarShareList || [];
                    const validShares = shares.filter(s => s && s.calShareId != null);
                    renderShareBadges(
                        validShares.map(s => s.calShareNm || '이름없음'),
                        validShares.map(s => s.calShareId)
                    );

                    // [첨부파일 미리보기 처리]
                    const previewArea = document.getElementById("FilePreview");
                    const fileNameDisplay = document.getElementById("fileNameDisplay");
                    previewArea.innerHTML = "";

                    const fileList = data.fileDetailVOList || [];
                    if (fileList.length > 0) {
                        fileNameDisplay.innerText = "📁 파일 변경";
                        fileList.forEach(file => {
                            const fileUrl = `/download?fileId=${file.fileId}&fileDtlId=\${file.fileDtlId}`;
                            const fileName = file.fileDtlONm.toLowerCase();
                            const isImage = fileName.match(/\.(jpg|jpeg|png|gif|webp)$/);

                            let content = "";
                            if (isImage) {
                                content = `
                                    <div class="file-item m-1" style="display:inline-block; position:relative;">
                                        <a href="\${fileUrl}" target="_blank">
                                            <img src="\${fileUrl}" style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd;">
                                        </a>
                                        <div class="small text-truncate" style="max-width: 100px;">\${file.fileDtlONm}</div>
                                    </div>`;
                            } else {
                                let iconClass = "fa-file-alt";
                                if (fileName.endsWith(".pdf")) iconClass = "fa-file-pdf text-danger";
                                else if (fileName.match(/\.(xls|xlsx)$/)) iconClass = "fa-file-excel text-success";
                                else if (fileName.match(/\.(doc|docx)$/)) iconClass = "fa-file-word text-primary";

                                content = `
                                    <a href="\${fileUrl}" class="text-decoration-none text-dark">
                                        <div class="file-item m-1 p-2 border rounded bg-light d-flex align-items-center" style="width: 180px; display:inline-flex !important;">
                                            <i class="fas \${iconClass} fa-lg me-2"></i>
                                            <div class="text-start" style="overflow:hidden;">
                                                <div class="small fw-bold text-truncate" style="max-width: 120px;">\${file.fileDtlONm}</div>
                                                <div class="x-small text-muted">\${(file.fileSize / 1024).toFixed(1)} KB</div>
                                            </div>
                                        </div>
                                    </a>`;
                            }
                            previewArea.innerHTML += content;
                        });
                    } else {
                        fileNameDisplay.innerText = "첨부파일 등록";
                    }

                    modal.style.display = 'block'; // 일반 일정 모달 오픈
                })
                .catch(err => {
                    console.error("상세 조회 에러: ", err);
                    AppAlert.error('조회 실패', '데이터를 가져오는 중 오류가 발생했습니다.', null, 'cloud_off');
                });
            },
	    });
    
    	calendar.render();

    	
    	// [커서 자동 이동] ----------------------------------------------------------------------------------------
    	const form = document.getElementById('scheduleForm');
    	const inputs = Array.from(form.querySelectorAll('input:not([type="hidden"]):not([type="checkbox"]):not([type="file"]), select, textarea'));

	    form.addEventListener('keydown', function(e) {
	        if (e.key === 'Enter') {
	            // textarea에서 엔터를 누를 때는 줄바꿈이 가능하도록 제외
	            if (e.target.tagName === 'TEXTAREA') return;
	
	            // 엔터의 기본 동작 방지
	            e.preventDefault();
	
	            const index = inputs.indexOf(e.target);
	            if (index > -1 && index < inputs.length - 1) {
	                // 다음 요소로 포커스 이동
	                inputs[index + 1].focus();
	            }
	        }
	    });



        // 일정별 해당 모달창 오픈
	    function openAnotherModal(type, data) {
            const modal = document.querySelector("#anotherDetailModal");
            const themeBar = document.querySelector("#modalThemeBar");
            const typeTitle = document.querySelector("#modalTypeTitle");
            const closeBtn = document.querySelector("#anotherListViewBtn");

            // 기본 초기화
            let themeColor = "#696cff";
            let titleText = "일정 상세";

            // 타입별 테마 설정
            if (type === 'project') {
                themeColor = "#91d4a8";
                titleText = "🚀 프로젝트 정보";
            } else if (type === 'vacation') {
                themeColor = "#f5a4b7";
                titleText = "🏖️ 연차 정보";
            } else if (type === 'bizTrip') {
                themeColor = "#fdc67e";
                titleText = "💼 출장 정보";
            } else if (type === 'reservation') {
                themeColor = "#566a7f";
                titleText = "🏢 회의실 예약 정보";
            }


            if(themeBar) themeBar.style.background = themeColor;
            if(typeTitle) typeTitle.innerText = titleText;
            if(closeBtn) {
                closeBtn.style.backgroundColor = themeColor; // 배경색 변경
                closeBtn.style.borderColor = themeColor;     // 테두리색 변경
                closeBtn.style.color = "#ffffff";            // 글자색은 흰색 고정
            }


            // 종료일 하루 빼기
            let displayEndDate = data.end || data.start || '-';

            if (type !== 'reservation' && data.end && data.end !== '-') {
                const dateObj = new Date(data.end);

                if (!isNaN(dateObj.getTime())) {
                    dateObj.setDate(dateObj.getDate() - 1);

                    const year = dateObj.getFullYear();
                    const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                    const day = String(dateObj.getDate()).padStart(2, '0');
                    displayEndDate = `\${year}-\${month}-\${day}`;
                }
            }


            // 데이터 채우기
            themeBar.style.background = themeColor;
            typeTitle.innerText = titleText;
            document.querySelector("#p_no").innerText = data.id || '-';
            document.querySelector("#p_title").innerText = data.title || '';
            document.querySelector("#p_startDate").innerText = data.start || '-';
            document.querySelector("#p_endDate").innerText = displayEndDate;

            modal.style.display = 'block';
        }

        // 모달 닫기 함수
        function closeAnotherModal() {
            const modal = document.querySelector("#anotherDetailModal");
            if(modal) {
                modal.style.display = 'none';
            }
        }

        window.addEventListener('click', function(e) {
            const anotherModal = document.querySelector("#anotherDetailModal");
            const commonModal = document.querySelector("#modal");
            if (e.target === anotherModal) {
                closeAnotherModal();
            }
        });

        window.openAnotherModal = openAnotherModal;
        window.closeAnotherModal = closeAnotherModal;
    	
	    

    	// [일정 등록] ---------------------------------------------------------------------------------
        document.querySelector("#saveBtn").addEventListener("click",()=>{
            const formData = new FormData();
            const loginId = document.querySelector("#loginId").value;
            formData.append("empId", loginId);
            formData.append("calTtl", document.querySelector("#title").value);
            formData.append("calCn", document.querySelector("#content").value);
            formData.append("calLocation", document.querySelector("#location").value);
            formData.append("calBgngDt", document.querySelector("#startDate").value);
            formData.append("calEndDt", document.querySelector("#endDate").value);
            
            const startTime = document.querySelector("#startTime").value;
            const endTime = document.querySelector("#endTime").value;
            formData.append("calBgngTm", document.querySelector("#startDate").value + " " + (startTime || "00:00") + ":00");
            formData.append("calEndTm", document.querySelector("#endDate").value + " " + (endTime || "00:00") + ":00");
            
            formData.append("calColor", "#8e91ff");
            formData.append("calImportant", document.querySelector("#importantBtn").checked ? 'Y' : 'N');
            
            const sharedIdsStr = document.querySelector("#sharedUserIds").value;
            formData.append("calShare", (sharedIdsStr && sharedIdsStr !== "") ? "Y" : "N");
            formData.append("calAllday", startTime ? 'N' : 'Y');
            formData.append("calStts", 'Y');

            // 공유 대상 리스트
            if (sharedIdsStr && sharedIdsStr !== "ALL") {
                const ids = sharedIdsStr.split(",");
                const selectedTabId = document.querySelector('input[name="shareType"]:checked').id;
                let shareType = (selectedTabId === 'typeIndividual') ? "개별" : (selectedTabId === 'typeDept' ? "부서" : "공유안함");

                ids.forEach((id, index) => {
                    formData.append(`calendarShareList[\${index}].calShareId`, id.trim());
                    formData.append(`calendarShareList[\${index}].calShareType`, shareType);
                });
            }

            // 첨부 파일
            const fileInput = document.querySelector("#calendarFile");
            if (fileInput.files.length > 0) {
                for (let i = 0; i < fileInput.files.length; i++) {
                    formData.append("multipartFiles", fileInput.files[i]); // 서버 MultipartFile[] 이름과 일치해야 함
                }
            }

            // 날짜 유효성 검사 공통 함수
            const checkDateValidity = () => {
                const startDate = document.querySelector("#startDate").value;
                const endDate = document.querySelector("#endDate").value;
                const startTime = document.querySelector("#startTime").value || "00:00";
                const endTime = document.querySelector("#endTime").value || "00:00";

                const startFull = new Date(startDate + " " + startTime);
                const endFull = new Date(endDate + " " + endTime);

                if (startFull > endFull) {
                    AppAlert.error('날짜 설정 오류', '종료 일시가 시작 일시보다 빠를 수 없습니다.');
                    return false;
                }
                return true;
            };

            if (!checkDateValidity()) {
                return; // 여기서 함수 실행을 중단시킴
            }

            axios.post("/calendar/addSchedule", formData, {
                headers: {
                    "Content-Type": "multipart/form-data"
                }
            })
            .then(response => {
                document.getElementById('addSchedule').style.display = 'none';
                calendar.refetchEvents();
                AppAlert.autoClose('등록 완료', '일정이 성공적으로 등록되었습니다.', 'event_available', 'success', 2000)
            })
            .catch(err => {
                AppAlert.error('등록 실패', '일정 저장 중 오류가 발생했습니다.');
            });
        });
        	

        
        
    	// [일정 수정] ---------------------------------------------------------
        document.querySelector("#updateBtn").addEventListener("click",()=>{
       	    const calNo = document.querySelector("#calNo").value;
       	 	const loginId = document.querySelector("#loginId").value;

       	    AppAlert.confirm('일정 수정', '내용을 수정하시겠습니까?', '수정하기', '취소', 'edit_calendar', 'primary')
                .then((result) => {
                // '수정' 버튼을 눌렀을 때만 실행
                if (result.isConfirmed) {
                    const formData = new FormData();
                    formData.append("calNo", calNo);
                    formData.append("empId", loginId);
                    formData.append("calTtl", document.querySelector("#title").value);
                    formData.append("calCn", document.querySelector("#content").value);
                    formData.append("calLocation", document.querySelector("#location").value);
                    formData.append("calBgngDt", document.querySelector("#startDate").value);
                    formData.append("calEndDt", document.querySelector("#endDate").value);

                    const startTime = document.querySelector("#startTime").value;
                    const endTime = document.querySelector("#endTime").value;
                    formData.append("calBgngTm", document.querySelector("#startDate").value + " " + (startTime || "00:00") + ":00");
                    formData.append("calEndTm", document.querySelector("#endDate").value + " " + (endTime || "00:00") + ":00");
                    formData.append("calColor", "#8e91ff");
                    formData.append("calImportant", document.querySelector("#importantBtn").checked ? 'Y' : 'N');

                    // 공유 리스트
                    const sharedIdsStr = document.querySelector("#sharedUserIds").value;
                    if (sharedIdsStr && sharedIdsStr.trim() !== "" && sharedIdsStr !== "ALL") {
                        const ids = sharedIdsStr.split(",");
                        const selectedTabId = document.querySelector('input[name="shareType"]:checked').id;
                        let shareType = (selectedTabId === 'typeIndividual') ? "개별" : (selectedTabId === 'typeDept' ? "부서" : "공유안함");

                        // 실제 유효한 ID 개수
                        let validIndex = 0;
                        ids.forEach((id) => {
                            const trimmedId = id.trim();
                            if (trimmedId !== "") { // 빈 문자열이 아닐 때만 추가
                                formData.append(`calendarShareList[\${validIndex}].calShareNo`, calNo);
                                formData.append(`calendarShareList[\${validIndex}].calShareId`, trimmedId);
                                formData.append(`calendarShareList[\${validIndex}].calShareType`, shareType);
                                validIndex++;
                            }
                        });
                    }
                    // 전체 공유
                    else if (sharedIdsStr === "ALL") {
                        formData.append("calShare", "Y");
                    }

                    // 새 파일 추가
                    const fileInput = document.querySelector("#calendarFile");
                    for (let i = 0; i < fileInput.files.length; i++) {
                        formData.append("multipartFiles", fileInput.files[i]);
                    }


                    // 날짜 유효성 검사 공통 함수
                    const checkDateValidity = () => {
                        const startDate = document.querySelector("#startDate").value;
                        const endDate = document.querySelector("#endDate").value;
                        const startTime = document.querySelector("#startTime").value || "00:00";
                        const endTime = document.querySelector("#endTime").value || "00:00";

                        const startFull = new Date(startDate + " " + startTime);
                        const endFull = new Date(endDate + " " + endTime);

                        if (startFull > endFull) {
                            AppAlert.error('날짜 설정 오류', '종료 일시가 시작 일시보다 빠를 수 없습니다.');
                            return false;
                        }
                        return true;
                    };

                    if (!checkDateValidity()) {
                            return; // 여기서 함수 실행을 중단시킴
                        }

                    axios.post("/calendar/update", formData, {
                        headers: { "Content-Type": "multipart/form-data" }
                    })
                    .then(response => {
                       if (response.data === "SUCCESS") {
                           document.getElementById('addSchedule').style.display = 'none';
                           calendar.refetchEvents();
                           AppAlert.autoClose('수정 완료', '일정이 변경되었습니다.', 'check_circle', 'success', 2000)
                       }
                    })
                    .catch(err => {
                        console.error(err);
                        AppAlert.error('수정 실패', '데이터 전송 중 오류가 발생했습니다.');
                    });
                }
            });
        });





        
     // [일정 삭제] -----------------------------------------------------------------
     document.querySelector("#deleteBtn").addEventListener("click",()=>{
	    const calNo = document.querySelector("#calNo").value;
        // const empId = document.querySelector("#empId").value;
         const title = document.querySelector("#title").value || "";
         const content = document.querySelector("#content").value || "";
         const location = document.querySelector("#location").value || "";
         const startDate = document.querySelector("#startDate").value || ""; // YYYY-MM-DD
         const startTime = document.querySelector("#startTime").value || ""; // HH:mm
         const endDate = document.querySelector("#endDate").value || "";
         const endTime = document.querySelector("#endTime").value || "";
         const important = document.querySelector("#importantBtn").checked ? 'Y' : 'N';
         const sharedUserIds = document.querySelector("#sharedUserIds").value || "";
         const sharedIdsStr = document.querySelector("#sharedUserIds").value;
         const selectedTabId = document.querySelector('input[name="shareType"]:checked').id;


		console.log("삭제 calNo : ", calNo);

	    const toSvnDate = (dateVal) => {
	        if (!dateVal) return "";
	        let d = (dateVal instanceof Date) ? dateVal.toISOString().split('T')[0] : String(dateVal).split(' ')[0];
	        return d.replace(/-/g, '/');
	    };

	    const sDate = toSvnDate(startDate);
	    const eDate = toSvnDate(endDate);

		const formattedStartTime = startDate.replace(/-/g, '/') + " " + (startTime || "00:00") + ":00";
		const formattedEndTime = endDate.replace(/-/g, '/') + " " + (endTime || "00:00") + ":00";


		const data = {
			"calNo": calNo,
		//  "empId": empId,
            "calTtl": title,
            "calCn": content,
            "calLocation": location,
            "calBgngDt": startDate,
            "calEndDt": endDate,
            "calBgngTm": formattedStartTime,  // TIMESTAMP용
            "calEndTm": formattedEndTime,     // TIMESTAMP용
            "calImportant": important,
            "calShare": (sharedIdsStr && sharedIdsStr !== "") ? "Y" : "N",
            "calAllday": startTime ? 'N' : 'Y', // 시간이 없으면 종일 일정
            "calStts": 'N',
            calendarShareList: []
		};
		console.log("삭제 data : ", data);

		axios.patch("/calendar/delete", data, {
			headers:{"Content-Type":"application/json;charset=utf-8"}
		})
			 .then(function(response) {
                 document.getElementById('addSchedule').style.display = 'none';
                 calendar.refetchEvents();
                 AppAlert.autoClose('삭제 완료', '일정이 삭제되었습니다.', 'delete_sweep', 'success', 2000)
             })
			 .catch(function(error) {
                 console.log("오류 발생", error);
                 AppAlert.error('삭제 실패', '서버 통신 중 오류가 발생했습니다.');
             });
     });	 
    	
	   

    // [일정 추가 버튼 클릭 시]
    document.querySelector(".write").onclick = function() {
        setModalMode('insert'); // 등록 모드로 버튼 변경
        modal.style.display = 'block';
    };

    // [취소 버튼 클릭 시]
    document.getElementById('closeBtn').onclick = function() {
        modal.style.display = 'none';
    };

    // [달력 크기 변경]
    document.querySelector(".csize").onclick = function() {
        let currentHeight = calendar.getOption('contentHeight');
        if(currentHeight === 700) {
            calendar.setOption('contentHeight', 'auto');
        } else {
            calendar.setOption('contentHeight', 700);
        }
    };

    // [첨부파일 선택 시 파일명 표시] --
    document.getElementById('calendarFile').addEventListener('change', function(e) {
        const fileName = e.target.files[0] ? e.target.files[0].name : "첨부파일을 선택하세요";
        document.getElementById('fileNameDisplay').textContent = fileName;
    });

    // [모달 바깥 클릭 시 닫기]
    window.addEventListener('click', function(event) {
        if (event.target == modal) {
            modal.style.display = 'none';
        }
    });
    
    
    
    
    
    // [공유 대상 선택] ------------------------------------------------------------
	const orgModal = document.getElementById('orgChartModal');
	const btnShareOpen = document.getElementById('share'); // 메인 모달의 '공유 대상 선택' 버튼
	const btnOrgClose = document.getElementById('closeOrgModal');
	
	// 공유 모달 열기
	btnShareOpen.onclick = function() {
	    orgModal.style.display = 'block';
	    
	    // 모달이 열릴 때 jsTree를 초기화
	    initJsTree(); 
	};
	
	// 공유 모달 닫기
	btnOrgClose.onclick = function() {
	    orgModal.style.display = 'none';
	};
	
	
    // 조직도(공유) 모달 배경 클릭 시 닫기
	window.addEventListener('click', function(event) {
	    if (event.target == orgModal) {
	        orgModal.style.display = 'none';
	    }
	});
    

    
    // 3. 탭 전환 로직 (개인/부서/전체)
	document.querySelectorAll('input[name="shareType"]').forEach(radio => {
	    radio.addEventListener('change', function(e) {
	        const id = e.target.id;
	        document.getElementById('treeArea').style.display = 'none';
	        document.getElementById('deptArea').style.display = 'none';
	        document.getElementById('allArea').style.display = 'none';
	
	        if (id === 'typeIndividual') {
	            document.getElementById('treeArea').style.display = 'block';
	        } else if (id === 'typeDept') {
	            document.getElementById('deptArea').style.display = 'block';
	            loadDeptList(); // 부서 리스트 가져오는 함수 호출
	        } else if (id === 'typeAll') {
	            document.getElementById('allArea').style.display = 'block';
	        }
	    });
	});
	
	
	
	// 4. 개인 선택 로직
	function initJsTree() {
	    if($('#jstree_div').jstree(true)) $('#jstree_div').jstree('destroy');
	    
	    // 직급 순서 정의
	    const rankPriority = { '대표': 1, '팀장': 2, '대리': 3, '주임': 4, '사원': 5 };
	
	    axios.get("/indivList").then(res => {
	        let treeData = [];
	        res.data.forEach(dept => {
	            // 부서
	            treeData.push({ 
	                id: "D" + dept.deptCd, 
	                parent: "#", 
	                text: dept.deptNm, 
	                type: "dept" 
	            });
	
	            if (dept.teamLeaders) {
	                // 팀장
	                dept.teamLeaders.forEach(leader => {
	                    treeData.push({ 
	                        id: leader.empId, 
	                        parent: "D" + dept.deptCd, 
	                        text: `\${leader.empNm} (\${leader.empJbgd})`, 
	                        type: "leader" 
	                    });
	                    
	                    // 팀원 정렬
	                    if (leader.teamEmployee && leader.teamEmployee.length > 0) {
	                        let sortedMembers = [...leader.teamEmployee].sort((a, b) => {
	                            const priorityA = rankPriority[a.empJbgd] || 99;
	                            const priorityB = rankPriority[b.empJbgd] || 99;
	                            
	                            if (priorityA !== priorityB) return priorityA - priorityB;
	                            return a.empNm.localeCompare(b.empNm); // 직급 같으면 이름순
	                        });
	
	                        sortedMembers.forEach(member => {
	                            treeData.push({ 
	                                id: member.empId, 
	                                parent: "D" + dept.deptCd, 
	                                text: `\${member.empNm} (\${member.empJbgd})`, 
	                                type: "default" 
	                            });
	                        });
	                    }
	                });
	            }
	        });
	
	        // jsTree 실행
	        $('#jstree_div').jstree({
	            core: { data: treeData, check_callback: true },
	            types: {
	                "default": { "icon": "fas fa-user text-secondary" },
	                "dept": { "icon": "fas fa-building text-primary" },
	                "leader": { "icon": "fas fa-user-tie text-warning" }
	            },
	            plugins: ['wholerow', 'checkbox', 'types']
	        }).bind("ready.jstree", () => $('#jstree_div').jstree("close_all"));
	    });
	}

	
	
	// 5. 부서 선택 로직
	function loadDeptList() {
	    const group = document.getElementById('deptListGroup');
	    group.innerHTML = '<div class="p-3 text-center text-muted" style="font-size: 13px;">부서 정보를 불러오는 중...</div>';
	    
	    axios.get("/partList").then(res => {
	        group.innerHTML = ""; 
	        if (res.data && res.data.length > 0) {
	            res.data.forEach(dept => {
	                // 인원수 처리
	                const memberCount = dept.deptCount || 0;
	
	                let html = `
	                    <label class="list-group-item d-flex align-items-center cursor-pointer border-0 border-bottom">
	                        <input class="form-check-input" type="checkbox" name="deptCheck" 
	                               value="\${dept.deptCd}" data-name="\${dept.deptNm}">
	                        
	                        <div class="d-flex align-items-center ms-2">
	                            <i class="fas fa-users text-primary me-2" style="font-size: 0.9rem;"></i> 
	                            <span class="dept-name" style="font-size: 14px; color: #566a7f; font-weight: 500;">\${dept.deptNm}</span>
	                            <span class="dept-count" style="font-size: 12px; color: #a1acb8; margin-left: 4px;">(\${memberCount})</span>
	                        </div>
	                    </label>`;
	                group.insertAdjacentHTML('beforeend', html);
	            });
	        } else {
	            group.innerHTML = "<div class='p-3 text-muted text-center'>부서 정보가 없습니다.</div>";
	        }
	    }).catch(err => {
	        console.error("부서 로드 실패:", err);
	        group.innerHTML = "<div class='p-3 text-danger text-center'>데이터 로딩 오류</div>";
	    });
	}

	
	// 6. 전체 선택 로직
	document.querySelectorAll('input[name="shareType"]').forEach(radio => {
	    radio.addEventListener('change', function(e) {
	        const id = e.target.id;

	        if (id === 'typeAll') {
	            document.getElementById('allArea').style.display = 'block';
	            // 전체 탭 클릭 시 자동으로 체크박스 체크
	            const allCheck = document.getElementById('allCheck');
	        }
	    });
	});
	
	
	// 공유 모달 열기 버튼
	btnShareOpen.onclick = function() {
	    orgModal.style.display = 'block';   // 모달 보이기
	
	    // 탭 라디오 버튼 초기화
	    const typeIndividual = document.getElementById('typeIndividual');
	    if(typeIndividual) typeIndividual.checked = true;
	
	    // 화면 영역 초기화
	    document.getElementById('treeArea').style.display = 'block';
	    document.getElementById('deptArea').style.display = 'none';
	    document.getElementById('allArea').style.display = 'none';
	
	    // 전체 체크박스 값 초기화
	    const allCheck = document.getElementById('allCheck');
	    if(allCheck) allCheck.checked = false;
	
	    // jsTree 데이터 갱신
	    if ($('#jstree_div').jstree(true)) {
	        $('#jstree_div').jstree("deselect_all"); 
	        $('#jstree_div').jstree("close_all");
	        $('#jstree_div').jstree(true).refresh();
	    } else {
	        initJsTree(); 
	    }
	};
	
	
	
	// 통합 데이터 수집 및 배지 생성
	document.getElementById('confirmShare').onclick = function() {
	    const selectedType = document.querySelector('input[name="shareType"]:checked').id; 
	    let selectedNames = [];
	    let selectedValues = [];

	    // 개인 선택 데이터 수집
	    if (selectedType === 'typeIndividual') {
	        const selectedNodes = $('#jstree_div').jstree("get_checked", true);
	        selectedNodes.forEach(node => {
	            if(node.original.type !== 'dept') {
	                selectedNames.push(node.text.split(' ')[0]); 
	                selectedValues.push(node.id); 
	            }
	        });
	    } 
	    // 부서 선택 데이터 수집
	    else if (selectedType === 'typeDept') {
	        document.querySelectorAll('input[name="deptCheck"]:checked').forEach(input => {
	            selectedNames.push(input.getAttribute('data-name')); 
	            selectedValues.push(input.value); 
	        });
	    } 
	    // 전체 선택
	    else if (selectedType === 'typeAll') {
	        selectedNames.push("전체");
	        selectedValues.push("ALL");
	    }

	    renderShareBadges(selectedNames, selectedValues);
	    orgModal.style.display = 'none';
	};

	
	// 공통 렌더링 함수
	function renderShareBadges(names, values) {
	    const container = document.getElementById('sharedUserDisplayContainer');
	    const hiddenInput = document.getElementById('sharedUserIds');
	    const wrapper = document.getElementById('sharedUserWrapper');
	
	    // share-badge를 가진 요소들을 삭제
	    container.querySelectorAll('.share-badge').forEach(b => b.remove());
	
	    if (values && values.length > 0) {
	        names.forEach((name, index) => {
	            const isAll = values[index] === "ALL";
	            const badge = document.createElement('span');
	            
	            badge.className = 'share-badge'; 
	            
	            badge.innerHTML = `
	                <i class="fas \${isAll ? 'fa-globe' : 'fa-user'}"></i>
	                <span>\${name}</span>
	                <i class="fas fa-times ms-1" onclick="removeOneUser('\${values[index]}', this)"></i>
	            `;
	            container.insertBefore(badge, hiddenInput);
	        });
	        
	        hiddenInput.value = values.join(",");
	        wrapper.style.display = 'block';
	    } else {
	        wrapper.style.display = 'none';
	        hiddenInput.value = "";
	    }
	}
	
	
	
	// 공유 대상 전체 취소 버튼
	window.clearShare = function() {
	    const hiddenInput = document.getElementById('sharedUserIds');
	    const wrapper = document.getElementById('sharedUserWrapper');
	    const container = document.getElementById('sharedUserDisplayContainer');
	    
	    // 요소가 존재할 때만 value 수정
	    if (hiddenInput) hiddenInput.value = "";
	    if (wrapper) wrapper.style.display = 'none';
	    if (container) {
	        container.querySelectorAll('.renderShareBadges').forEach(b => b.remove());
	    }
	
	    const displayInput = document.getElementById('sharedUserDisplay');
	    if (displayInput) displayInput.value = "";
	    
	    // 선택 데이터 초기화 (jstree)
	    if (typeof $ !== 'undefined' && $('#jstree_div').jstree(true)) {
	        $('#jstree_div').jstree("uncheck_all");
	        $('#jstree_div').jstree("close_all");
	    }
	
	    // 부서 및 전체 체크박스 초기화
	    document.querySelectorAll('input[name="deptCheck"], #allCheck').forEach(cb => cb.checked = false);
	};
	
	
	
	// 개별 삭제 버튼 기능
	window.removeOneUser = function(id, element) {
	    const hiddenInput = document.getElementById('sharedUserIds');
	    const container = document.getElementById('sharedUserDisplayContainer');
	    const wrapper = document.getElementById('sharedUserWrapper');
	
	    if (!hiddenInput || !container) return;
	
	    // 기존 값들에서 삭제할 ID 제외 (쉼표 기준 분리 및 필터링)
	    let values = hiddenInput.value.split(",").filter(v => v !== id && v !== "");
	    
	    // hidden input 값 업데이트
	    hiddenInput.value = values.join(",");
	
	    // 배지 UI 삭제
	    const badge = element.closest('.renderShareBadges');
	    if (badge) {
	        badge.remove();
	    }
	
	    // 남은 값이 없으면 전체 영역 숨김
	    if (values.length === 0) {
	        wrapper.style.display = 'none';
	        hiddenInput.value = "";
	    }
	};
	
	
	
	
	
	
	// [첨부파일 미리보기] ------------------------------------------------------
	document.getElementById('calendarFile').addEventListener('change', function(e) {
		const files = Array.from(e.target.files); // 선택된 파일들을 배열로 변환
	    const fileNameDisplay = document.getElementById("fileNameDisplay");
	    const Preview = document.getElementById("FilePreview");

	    Preview.innerHTML = "";

	    if (files.length === 0) {
	        fileNameDisplay.innerText = "클릭하여 첨부파일을 업로드하세요";
	        return;
	    }

	    // 파일 개수
	    fileNameDisplay.innerText = files.length + "개의 파일이 선택됨";

	    files.forEach(file => {
		    const reader = new FileReader();
		    reader.onload = function(event) {
		    	let content = "";

	            if (file.type.match("image.*")) {
	                // 이미지 파일 미리보기
	                content = `
	                    <div class="file-item m-1" style="display:inline-block; position:relative;">
	                        <img src="\${event.target.result}" 
	                             style="width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd;">
	                        <div class="small text-truncate" style="max-width: 100px;">\${file.name}</div>
	                    </div>
	                `;
	            } else {
	                // 일반 파일 아이콘 표시
	                let iconClass = "fa-file-alt"; 
	                if (file.name.endsWith(".pdf")) iconClass = "fa-file-pdf text-danger";
	                else if (file.name.match(/(.xls|.xlsx)$/)) iconClass = "fa-file-excel text-success";
	                else if (file.name.match(/(.doc|.docx)$/)) iconClass = "fa-file-word text-primary";
	                else if (file.name.match(/(.hwp)$/)) iconClass = "fa-file-lines text-info";

	                content = `
	                    <div class="file-item m-1 p-2 border rounded bg-light d-flex align-items-center" style="width: 180px; display:inline-flex !important;">
	                        <i class="fas \${iconClass} fa-lg me-2"></i>
	                        <div class="text-start" style="overflow:hidden;">
	                            <div class="small fw-bold text-truncate" style="max-width: 120px;">\${file.name}</div>
	                            <div class="x-small text-muted">\${(file.size / 1024).toFixed(1)} KB</div>
	                        </div>
	                    </div>
	                `;
	            }
	            Preview.innerHTML += content;
		    };
		    reader.readAsDataURL(file);
	    });
	});
	
	
	// [첨부파일 저장 로직] -----------------------------------------------------------------------------
	function submit() {
		const formData = new FormData();
		
		formData.append("calTtl", document.getElementById("calTtl").value);
		formData.append("calCn", window.editor.getData());
		
		const fileInput = document.getElementById("calendarFile");
		for(let i=0; i<files.length; i++) {
			formData.append("uploadFile", fileInput.files[i]);
		}
		
		axios.post("/addSchedule", formData, {
			headers:{"Content-Type":"multipart/form-data"}
		})
			.then(res => {
				console.log("res : ", res.data);
				
		})
	}
	
	
	
	// [연차] -----------------------------------------------------------------------------
	const vacCkbox = document.getElementById('checkVacation'); 

	vacCkbox.addEventListener('change', function() {
	    // 기존 소스 중복 방지를 위해 먼저 삭제
	    const oldSource = calendar.getEventSourceById('vacSource');
	    if (oldSource) oldSource.remove();

	    if(this.checked) {
	        // currentSelectedEmpId가 있으면 팀원꺼, 없으면 내꺼
	        const url = `/calendar/vacation?empId=\${currentSelectedEmpId || ""}`;
	        
	        calendar.addEventSource({
	            id: 'vacSource',
	            url: url,
	            method: 'GET',
	            success: function(data) {
	                return data.map(item => ({
	                    title: `[연차] \${item.vctDocCd}`,
	                    start: item.vctDocBgng,
	                    end: item.vctDocEnd,
	                    backgroundColor: '#f2a3b3',
	                    allDay: true,
	                    extendedProps: { type: 'vacation' } 
	                }));
	            }
	        });
	    }
	});
	
	
	// [출장] -----------------------------------------------------------------------------
	const bizCkbox = document.getElementById('checkBizTrip'); 

	bizCkbox.addEventListener('change', function() {
	    const oldSource = calendar.getEventSourceById('bizSource');
	    if (oldSource) oldSource.remove();

	    if(this.checked) {
	        const url = `/calendar/bztrip?empId=\${currentSelectedEmpId || ""}`;
	        calendar.addEventSource({
	            id: 'bizSource', 
	            url: url,
	            method: 'GET',
	            success: function(data) {
	                return data.map(item => ({
	                    title: `[출장] \${item.bztrpPlc}`, 
	                    start: item.bztrpStart,
	                    end: item.bztrpEnd, 
	                    backgroundColor: '#ffab00',
	                    allDay: true
	                }));
	            }
	        });
	    }
	});


    // [연차/출장 카운트] --------------------------------------------------------
    $(document).ready(function() {
        const loginId = $('#loginId').val();
        updateStats(loginId);
    });

    function updateStats(empId) {
        $.ajax({
            url: '/calendar/stats',
            type: 'GET',
            data: { empId: empId },
            success: function(res) {
                console.log("서버 응답 데이터:", res);

                // 연차 숫자 업데이트
                if(res.vctStats) {
                    const v = res.vctStats;
                    $('#vctCount').text(`(\${v.monthCount || 0}/\${v.totalCount || 0}/15)`);
                }
                // 출장 숫자 업데이트
                if(res.bzStats) {
                    const b = res.bzStats;
                    $('#bzCount').text(`(\${(b.monthCount || 0) - 1}/\${b.totalCount || 0})`);
                }
            }
        });
    }





    // [임시 데이터 버튼] --------------------------------------------------------------
    document.getElementById('autoFillBtn').addEventListener('click', function() {
    // 1. 현재 날짜 가져오기 (YYYY-MM-DD)
    const now = new Date();
    const today = now.toISOString().split('T')[0];

    // 2. 제목 및 상세내용 채우기
    document.getElementById('title').value = "프로젝트 주간 성과 보고 회의";
    document.getElementById('location').value = "본사 3층 소회의실";
    document.getElementById('content').value = "1. 지난주 업무 실적 검토\n2. 이번주 신규 이슈 공유\n3. 부서 간 협업 사항 논의";

    // 3. 날짜 세팅
    document.getElementById('startDate').value = today;
    document.getElementById('endDate').value = today;

    // 4. 시간 세팅 (시작 10:00 / 종료 11:00 예시)
    const startSelect = document.getElementById('startTime');
    const endSelect = document.getElementById('endTime');

    if(startSelect) startSelect.value = "10:00";
    if(endSelect) endSelect.value = "11:00";

    // 5. 중요한 일정 체크 (옵션)
    document.getElementById('importantBtn').checked = true;

    console.log("샘플 데이터가 입력되었습니다.");
    });


	
	// [실시간 알림 구독 추가] ---------------------------------------------------------
    /*
    function initAlarmSubscription() {
        const loginId = document.querySelector("#loginId")?.value;
        if (!loginId) return;

        // 웹소켓 연결 상태를 확인하며 구독 시도
        const checkAndSubscribe = setInterval(() => {
            // stompClient는 보통 상위(layout/header)에서 선언됨
            if (window.stompClient && window.stompClient.connected) {
                
                window.stompClient.subscribe('/sub/alarm/' + loginId, function(response) {
                    const alarmData = JSON.parse(response.body);
                    
                    // 1. 커스텀 알림창 띄우기 (작성하신 showAlert 함수 활용)
                    if (typeof window.showAlert === 'function') {
                        window.showAlert(alarmData.almMsg, 'success');
                    } else {
                        // showAlert이 전역이 아닐 경우 기본 alert
                        alert(alarmData.almMsg);
                    }

                    // 2. (선택사항) 알림 종소리 숫자 카운트 업데이트 로직 호출
                    // if(typeof updateAlarmCount === 'function') updateAlarmCount();
                });

                console.log("알림 구독 성공: /sub/alarm/" + loginId);
                clearInterval(checkAndSubscribe); // 구독 성공 시 반복 중단
            }
        }, 1000); // 1초마다 연결 상태 확인
    }

    initAlarmSubscription();
	*/



	// 신청 내역 보기 클릭 시 - 출장/연차/프로젝트/회의실 예약 페이지로 이동
	function goToListView(type, targetId) {
        console.log("이동 타입:", type, " / 대상 ID:", targetId);

        if (!targetId || targetId === '-') {
            AppAlert.warning('정보 없음', '상세 정보를 찾을 수 없는 일정입니다.', null, 'search_off');
            return;
        }

        switch(type) {
            case 'project':
                location.href = `/myproject/detail/\${targetId}`;
                break;

            case 'reservation':
                location.href = `/reserveList`;
                break;

            case 'vacation':
            case 'bizTrip':
                location.href = `/attendance-view`;
                break;

            default:
                // 그 외 근태 관련은 현재 페이지의 '리스트 탭'으로 (기존 유지)
                if (typeof switchView === 'function') {
                    switchView('list');
                } else {
                    location.href = `/attendance-view`;
                }
        }
    }
});
</script>



<!-- 헤더 기능 -->
<script>
$(document).ready(function() {
    // 기존 부트스트랩 이벤트와 충돌을 피하기 위해 전역 클릭 관리
    $(document).on('click', '[data-bs-toggle="dropdown"]', function(e) {
        e.preventDefault();
        e.stopPropagation();

        var $menu = $(this).next('.dropdown-menu');
        var isShow = $menu.hasClass('show');
        
        $('.dropdown-menu').removeClass('show');
        if (!isShow) {
            $menu.addClass('show');
        }

        // 모든 메뉴 닫기
        $('.dropdown-menu').removeClass('show');
        $('[data-bs-toggle="dropdown"]').attr('aria-expanded', 'false');

        // 클릭한 것만 토글
        if (!isShow) {
            $menu.addClass('show');
            $(this).attr('aria-expanded', 'true');
        }
    });

    // 메뉴 외부 클릭 시 닫기
    $(document).on('click', function (e) {
        if (!$(e.target).closest('.dropdown').length) {
            $('.dropdown-menu').removeClass('show');
            $('[data-bs-toggle="dropdown"]').attr('aria-expanded', 'false');
        }
    });
});
</script>