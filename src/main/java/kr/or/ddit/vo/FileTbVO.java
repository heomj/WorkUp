package kr.or.ddit.vo;

import java.util.Date;
import java.util.List;
import lombok.Data;

@Data
public class FileTbVO {
    // FILE_TABLE 테이블 컬럼
    private Long fileId;        // 파일 그룹 번호 (PK, 시퀀스 사용)
    private int empId;         // 등록자 사번
    private Date fileDate;     // 등록 일시 (기본값 SYSDATE)
    private String fileStts;   // 파일 분류 (예: 공지사항, 자유게시판, 프로필 등)
    private String fileDelYn;  // 삭제 여부 (기본값 'N')

    // 1:N 관계를 위한 상세 파일 리스트
    // 하나의 파일 그룹(마스터)은 여러 개의 상세 파일을 가질 수 있습니다.
    private List<FileDetailVO> fileDetailVOList;
}