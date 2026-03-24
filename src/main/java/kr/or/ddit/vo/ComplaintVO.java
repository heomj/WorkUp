package kr.or.ddit.vo;

import java.util.Date;
import lombok.Data;

/**
 * 신고 테이블(COMPLAINT) 매핑 VO
 */
@Data
public class ComplaintVO {
	// 1. 테이블 컬럼 매핑 필드
    private int dclNo;          // 신고번호 (DCL_NO / NUMBER / PK)
    private int dclBbsNo;       // 게시글번호 (DCL_BBS_NO / NUMBER / FK)
    private int empId;          // 신고작성자 사번 (EMP_ID / NUMBER)
    private String dclCn;       // 신고사유 (DCL_CN / VARCHAR2(1000))
    private Date dclDt;          // 신고일시 (DCL_DT / DATE)
    private String dclStts;     // 신고처리상태 (DCL_STTS / VARCHAR2(50))
    private Integer dclPrcsId;  // 신고처리자ID (DCL_PRCS_ID / NUMBER) - Null 가능하므로 Integer
    private Date dclPrcsDt;     // 신고처리시점 (DCL_PRCS_DT / DATE)
    private String dclPrcsCn;   // 신고처리내용 (DCL_PRCS_CN / VARCHAR2(1000))

    // 2. JOIN 및 추가 비즈니스 로직용 필드
    private String reporterNm;  // 신고자 이름
    private String bbsTitle;    // 신고된 게시물 제목
    private int writerId;       // 게시글 작성자 사번 (BBS_BOARD.EMP_ID)
    
    // [추가] 3진 아웃 로직을 위한 신고 누적 횟수 필드
    private int reportCnt;      // 해당 게시물의 현재 누적 신고 횟수
    private String bbsCn;		// 게시글 내용
    private int almNo;
}