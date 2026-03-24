package kr.or.ddit.vo;

import lombok.Data;
import java.util.Date;

@Data
public class FileDetailVO {
    private Long fileDtlId;        // 파일 상세 PK
    private Long fileId;           // 파일 마스터 ID (FK)
    private String fileDtlPath;   // 저장 경로
    private String fileDtlSaveNm; // 저장 파일명 (UUID 등)
    private String fileDtlONm;    // 원본 파일명
    private String fileDtlExt;    // 확장자
    private Date fileDtlDt;       // 등록 일시
    private int empId;            // 등록자 사번
    private String fileDtlDelYn;  // 삭제 여부
}