package kr.or.ddit.vo;

import lombok.Data;

@Data
public class ExpndDocVO {


    // 1. 마스터/디테일 관계용 FK (나중에 컨트롤러에서 세팅)
    private int expndDocNo;    // 지출 마스터 신청번호 (FK)
    private int expndDtlNo;    // 상세 내역 PK

    // 2.JSP의 formData.append 키 값과 1:1로 일치해야 하는 필드들
    private int bgtCd;         // 예산 비목 코드
    private int bgtMCd;        // 예산 마스터 코드 (부서 예산 코드)
    private long expndAmt;     // 지출 금액
    private String expndRsn;   // 지출 사유 (적요)

    // 나중에 화면 조회 시 보여줄 비목 이름
    private String bgtItmNm;

}
