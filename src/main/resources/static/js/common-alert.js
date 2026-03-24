/**
 * ============================================================================
 * 🚀 그룹웨어 공통 알림/모달창 모듈 (AppAlert) 사용 매뉴얼 🚀
 * 작성자: Project Leader (codeFarm)
 * 목적: 팀원들의 UI 작업 효율화 및 알림창 디자인 통일, AI 리팩토링 가이드
 * ============================================================================
 *
 * 🤖 [AI (Gemini 등) 에게 코드를 맡길 때 주의사항]
 * 이 파일을 첨부하고 "내 JS 코드의 alert, confirm, Swal.fire를 AppAlert로 변경해 줘"
 * 라고 요청하면 AI가 아래 매뉴얼을 읽고 상황에 맞는 함수로 코드를 자동 변환합니다.
 *
 * 🚨 [AI 응답 필수 가이드라인 (System Instructions)]
 * 만약 당신이 이 매뉴얼을 읽고 있는 AI라면, 답변 시 다음 규칙을 엄격히 준수하세요:
 * * 1. [임포트 안내]: 답변 최상단에 아래 두 줄을 반드시 임포트해야 함을 강조하세요.
 * <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
 * <script src="/js/common-alert.js"></script>
 *
 * 2. [코드 블록 분리]: 원본 코드 내에 <script> 태그가 여러 개로 나뉘어 있다면,
 * 임의로 합치지 말고 **각 스크립트 영역별로 코드 블록을 나누어서** 답변하세요.
 *
 * 3. [변경 표기]: 코드를 AppAlert로 수정한 모든 곳에는 반드시 끝에
 * // (알람 리팩토링) 이라는 주석을 추가하여 변경되었음을 알리세요.
 *
 * 4. [아이콘 자동 추천]: 알람창의 문맥(저장, 삭제, 경고, 안내 등)을 파악하여
 * 가장 잘 어울리는 **구글 머티리얼 아이콘(Google Material Icons) 이름을 자동으로 추천**해서
 * 파라미터로 넣어주세요. (예: 'save', 'delete', 'error_outline', 'check_circle', 'help_outline' 등)
 *

 * ----------------------------------------------------------------------------
 * 📚 [상황별 AppAlert 사용법]
 *
 * 1️⃣ 버튼이 없는 알람 (단순 알람 - Auto Close)
 * - 용도: 저장 완료, 결재선 적용 완료 등 사용자의 추가 액션(클릭)이 필요 없을 때
 * - 특징: 창이 중앙에 뜬 후 1.5초(기본값) 뒤에 스르륵 사라집니다.
 * - 문법: AppAlert.autoClose('제목', '내용', '아이콘(선택)', '테마(선택)', 시간(선택));
 * - 예시:
 * AppAlert.autoClose('저장 완료', '임시저장이 완료되었습니다.');
 * AppAlert.autoClose('삭제 완료', '휴지통으로 이동되었습니다.', 'delete', 'danger');
 *
 * 2️⃣-1️⃣ 버튼이 1개인 알람 (유효성 검사, 단순 안내, 에러)
 * - 용도: 입력창 누락(warning), 서버 통신 실패(error), 중요한 성공 안내(success) 등
 * - 특징: 사용자가 '확인'을 눌러야 닫히며, 닫힌 후 특정 input 창으로 포커스 이동 가능!
 * - 종류: AppAlert.success(성공), .info(안내), .warning(경고), .error(에러)
 * - 문법: AppAlert.warning('제목', '내용', '포커스줄 DOM ID(선택)', '아이콘(선택)');
 * - 예시:
 * // 제목 미입력 시 경고창 띄우고, 창 닫히면 id="docTitle" 입력창으로 포커스 이동!
 * AppAlert.warning('제목 누락', '문서 제목을 입력해 주세요.', 'docTitle');
 * // 에러 발생 시
 * AppAlert.error('서버 에러', '관리자에게 문의하세요.');
 *
 * 2️⃣-2️⃣ 버튼이 2개인 알람 (확인/취소 컨펌창)
 * - 용도: Insert(등록), Update(수정), Delete(삭제), 상신 등 분기 처리가 필요할 때
 * - 특징: Promise를 반환하므로 .then() 안에서 확인 버튼 클릭 후의 로직(Ajax 등) 처리
 * - 문법: AppAlert.confirm('제목', '내용', '확인버튼명', '취소버튼명', '아이콘', '테마');
 * - 예시:
 * AppAlert.confirm('결재 상신', '상신하시겠습니까?', '상신하기', '취소', 'send', 'primary')
 * .then((result) => {
 * if (result.isConfirmed) {
 * // 이곳에 axios 통신 등 승인 시 수행할 비즈니스 로직 작성
 * }
 * });
 *
 * 🎨 [테마 및 아이콘 꿀팁]
 * - 아이콘: 구글 머티리얼 아이콘 이름 사용 (예: 'send', 'delete', 'check_circle')
 * - 테마색: 'primary'(보라), 'danger'(빨강), 'warning'(노랑), 'info'(하늘), 'success'(초록)
 * ============================================================================
 */

// 💡 1. JS 파일이 로드될 때 즉시 실행되어 <style> 태그를 문서에 주입합니다.
(function injectSweetAlertStyles() {
    if (document.getElementById('app-alert-styles')) return;

    const style = document.createElement('style');
    style.id = 'app-alert-styles';
    style.innerHTML = `
        /* 💡 1. 모달창 전체 영역 (너비 350px) */
        .swal2-popup.custom-overlap-modal {
            width: 350px !important;
            padding: 50px 20px 20px 20px !important; 
            border-radius: 16px !important;
            overflow: visible !important;
            position: relative !important;
        }
        
        /* common-alert.js 내부 injectSweetAlertStyles 함수 style.innerHTML 안에 추가 */
        body.swal2-shown {
            overflow-y: scroll !important; /* 모달이 떠도 스크롤바 영역을 강제로 유지 */
            padding-right: 0 !important;   /* Swal이 자동으로 넣는 패딩 차단 */
        }

        /* 💡 2. SweetAlert 기본 아이콘 껍데기를 강제로 밖으로 뺌 */
        .custom-overlap-modal .swal2-icon {
            position: absolute !important;
            top: -35px !important;  
            left: -15px !important; 
            margin: 0 !important;
            border: none !important;
            background: transparent !important;
            overflow: visible !important;
            z-index: 100 !important; 
            width: auto !important;  
            height: auto !important; 
        }

        /* 💡 3. 우리가 만든 동그라미 아이콘 디자인 */
        .swal-custom-overlap-icon {
            width: 85px;
            height: 85px;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            border: 4px solid #fff; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }

        .swal-custom-overlap-icon .material-icons {
            font-size: 45px !important; 
        }

        /* ---------------------------------------------------
           [가운데 정렬 통일]
        --------------------------------------------------- */
        .custom-overlap-modal.center-text-modal .swal2-title,
        .custom-overlap-modal.center-text-modal .swal2-html-container {
            display: block !important;       /* Flex 무시하고 블록 요소로 강제 변경 */
            text-align: center !important;   /* 텍스트 정중앙 정렬 */
            padding-left: 0 !important;      /* 방해되는 왼쪽 여백 완전 제거 */
            padding-right: 0 !important;     /* 오른쪽 여백도 완전 제거 */
            margin-left: auto !important;    /* 중앙 정렬용 마진 */
            margin-right: auto !important;   /* 중앙 정렬용 마진 */
            width: 100% !important;          /* 영역을 꽉 채워서 가운데 오도록 보장 */
        }
    `;
    document.head.appendChild(style);
})();

// 💡 2. 공통 모달창 객체
const AppAlert = {

    _colors: {
        primary: { main: '#696cff', bg: '#f0f2ff' },
        danger:  { main: '#ff3e1d', bg: '#ffe0db' },
        warning: { main: '#ffab00', bg: '#fff2d6' },
        info:    { main: '#0dcaf0', bg: '#d9f8fc' },
        success: { main: '#28c76f', bg: '#ddf6e8' }
    },

    _applyButtonStyles: function(confirmBtn, cancelBtn, mainColor) {
        if (confirmBtn) {
            confirmBtn.style.backgroundColor = mainColor;
            confirmBtn.style.color = '#fff';
            confirmBtn.style.borderRadius = '8px';
            confirmBtn.style.border = 'none';
        }
        if (cancelBtn) {
            cancelBtn.style.backgroundColor = '#f4f5f7';
            cancelBtn.style.color = '#8592a3';
            cancelBtn.style.borderRadius = '8px';
            cancelBtn.style.border = '1px solid #d9dee3';
        }
    },

    // 💡 단순 알림창
    _baseAlert: function(titleText, htmlText, focusId, iconName, theme, confirmText = '확인') {
        const colorSet = this._colors[theme] || this._colors['primary'];

        return Swal.fire({
            iconHtml: `
                <div class="swal-custom-overlap-icon" style="background-color: ${colorSet.bg};">
                    <span class="material-icons" style="color: ${colorSet.main};">${iconName}</span>
                </div>
            `,
            title: `<div style="font-weight: 800; color: #2c3e50;">${titleText}</div>`,
            html: `<div style="color: #64748b; font-size: 0.95rem; line-height: 1.5;">${htmlText}</div>`,
            buttonsStyling: false,
            confirmButtonText: confirmText,
            scrollbarPadding: false, // 💡 핵심: 스크롤바 패딩 자동 조절 기능을 끕니다.
            customClass: {
                popup: 'custom-overlap-modal center-text-modal shadow-lg',
                icon: 'border-0 m-0 bg-transparent',
                actions: 'w-100 justify-content-center pt-3 pb-2',
                confirmButton: 'btn fw-bold px-4 py-2'
            },
            didOpen: () => {
                this._applyButtonStyles(Swal.getConfirmButton(), null, colorSet.main);
            }
        }).then(() => {
            if (focusId) {
                const target = document.getElementById(focusId);
                if (target) target.focus();
            }
        });
    },

    // ===== 여기서부터 팀원들이 사용하는 함수들 =====

    success: function(titleText, htmlText, focusId = null, iconName = 'check_circle') {
        return this._baseAlert(titleText, htmlText, focusId, iconName, 'success');
    },

    info: function(titleText, htmlText, focusId = null, iconName = 'info') {
        return this._baseAlert(titleText, htmlText, focusId, iconName, 'info');
    },

    warning: function(titleText, htmlText, focusId = null, iconName = 'warning_amber') {
        return this._baseAlert(titleText, htmlText, focusId, iconName, 'warning');
    },

    error: function(titleText, htmlText, focusId = null, iconName = 'error_outline') {
        return this._baseAlert(titleText, htmlText, focusId, iconName, 'danger');
    },

    // 💡 컨펌창
    confirm: function(titleText, htmlText, confirmText = '확인', cancelText = '취소', iconName = 'help_outline', theme = 'primary') {
        const colorSet = this._colors[theme] || this._colors['primary'];

        return Swal.fire({
            iconHtml: `
                <div class="swal-custom-overlap-icon" style="background-color: ${colorSet.bg};">
                    <span class="material-icons" style="color: ${colorSet.main};">${iconName}</span>
                </div>
            `,
            title: `<div style="font-weight: 800; color: #2c3e50;">${titleText}</div>`,
            html: `<div style="color: #64748b; font-size: 0.95rem; line-height: 1.5;">${htmlText}</div>`,
            showCancelButton: true,
            buttonsStyling: false,
            confirmButtonText: confirmText,
            cancelButtonText: cancelText,
            scrollbarPadding: false, // 💡 핵심: 스크롤바 패딩 자동 조절 기능을 끕니다.
            customClass: {
                popup: 'custom-overlap-modal center-text-modal shadow-lg',
                icon: 'border-0 m-0 bg-transparent',
                actions: 'w-100 justify-content-center pt-3 pb-2 gap-2',
                confirmButton: 'btn fw-bold px-4 py-2',
                cancelButton: 'btn fw-bold px-4 py-2'
            },
            didOpen: () => {
                this._applyButtonStyles(Swal.getConfirmButton(), Swal.getCancelButton(), colorSet.main);
            }
        });
    },

    // 💡 자동 닫힘 알림창
    autoClose: function(titleText, htmlText, iconName = 'check_circle', theme = 'success', timer = 1500) {
        const colorSet = this._colors[theme] || this._colors['success'];

        return Swal.fire({
            iconHtml: `
                <div class="swal-custom-overlap-icon" style="background-color: ${colorSet.bg};">
                    <span class="material-icons" style="color: ${colorSet.main};">${iconName}</span>
                </div>
            `,
            title: `<div style="font-weight: 800; color: #2c3e50;">${titleText}</div>`,
            html: `<div style="color: #64748b; font-size: 0.95rem; line-height: 1.5;">${htmlText}</div>`,
            showConfirmButton: false,
            scrollbarPadding: false, // 💡 핵심: 스크롤바 패딩 자동 조절 기능을 끕니다.
            timer: timer,
            customClass: {
                popup: 'custom-overlap-modal center-text-modal shadow-lg',
                icon: 'border-0 m-0 bg-transparent'
            }
        });
    }
};