package kr.or.ddit.vo;

import java.util.Date;
import lombok.Data;

@Data
public class CommentVO {
    private int cmntNo;        // 댓글 번호 (PK)
    private int cmntBbsNo;     // 게시글 번호 (FK: BBS_BOARD)
    private int empId;         // 작성자 사번 (FK: EMPLOYEE)
    private String cmntCn;     // 댓글 내용
    private Date cmntDt;       // 등록 일시
    private String cmntDelYn;  // 삭제 여부 (기본값 'N')
    private Integer cmntUpNo;  // 상위 댓글 번호 (대댓글용, NULL 허용을 위해 Integer)

    // JOIN 결과 및 가공 필드
    private String empNm;      // 작성자 성명
    private String empProfile; // 회원 프로필 경로
    private String avtSaveNm; // (아바타 파일명 매핑용)
}