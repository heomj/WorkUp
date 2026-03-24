package kr.or.ddit.vo;

import lombok.Data;

/**
 * 예약 시스템 통합 Value Object (VO)
 * 사용자 예약 및 관리자 마스터 자산 관리 겸용
 */
@Data
public class ReserveVO {
    
    // ==========================================
    // 1. 공통 및 통합 식별 정보
    // ==========================================
    private String type;          // 예약 유형 구분 ('ROOM' 또는 'FIXTURE')
    private String resId;         // 통합 예약 번호 (PK: 수정 및 삭제 시 식별자로 사용)
    private String empId;         // 신청자 사번 (로그인 세션 정보와 연동)
    private String empNm;         // 신청자 이름 
    private String expln;         // 사용 목적 및 대여 사유
    private String rsvtDt;        // 예약 신청 일시
    private String bgngDt;        // 사용/대여 시작 일시 
    private String endDt;         // 사용/반납 종료 일시 
    private String stts;          // 진행 상태 
    private String title;         // UI 출력용 명칭
    
    // ==========================================
    // 2. 결재 및 승인 정보
    // ==========================================
    private String aprvId;        // 지정된 승인권자(팀장/관리자 등)의 사번
    private String aprvDt;        // 승인 완료 일시 (null일 경우 '승인 대기' 상태)

    // ==========================================
    // 3. 회의실 전용 데이터 (MEETING_ROOM 테이블)
    // ==========================================
    private int rmNo;             // 회의실 고유 번호
    private String rmNm;          // 회의실 이름 (예: 대회의실 A)
    private String rmPlc;         // 회의실 위치 (예: 1층 로비)
    private int rmActcNope;       // 수용 가능 인원 수
    private String rmStts;        // 회의실 현재 상태 ('01', '02' 등)

    // ==========================================
    // 4. 비품/자산 전용 데이터 (FIXTURE 테이블)
    // ==========================================
    private int fixtNo;           // 비품 고유 번호
    private String fixtCat;       // 비품 분류 ('전자기기', '일반비품', '소모품')
    private String fixtNm;        // 항목 명칭 (예: 노트북, 빔프로젝터)
    private String fixtPlc;       // 보관 위치
    private int fixtQty;          // 재고 수량
    private String fixtStts;      // 비품 상태
    private String fixtRegDt;     // 등록 일시

    // ==========================================
    // 5. 모델명 연동 (FIXTURE_MODEL 테이블)
    // ==========================================
    private String fixtMdNm;      // 비품 모델명
    private String assetNo;       // 자산번호 (리액트 화면에서 괄호() 안에 표시됨)

    // ==========================================
    // 6. [신규 추가] 관리자 제어: 상태 유지 기간 설정
    // ==========================================
    private String sttsBgngDt;    // 상태 유지 시작일 (YYYY-MM-DD)
    private String sttsEndDt;     // 상태 유지 종료일 (YYYY-MM-DD)
    
   
}