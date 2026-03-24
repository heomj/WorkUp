package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class BudgetMasterVO {

    private int bgtMCd;
    private int deptCd;
    private int bgtYr;
    private long bgtTotAmt;
    private String bgtStts;
    private String bgtRegDt;

    // 🚨 로그 저장을 위해 "정확한 이름"으로 추가해야 할 필드들
    private String bgtChgSe;   // 변경 구분 (신규배정 등)
    private String bgtChgRsn;  // 👈 범인! 정확히 이 이름이어야 함 (bgt'Chg'Rsn)
    private int aprvNo;        // 전자결재 번호
    private String empId;      // 담당자 사번
    private int bgtCd;         // 비목 코드

    //비목 배열 리스트
    private List<BudgetDetailVO> details;

}
