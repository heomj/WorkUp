package kr.or.ddit.vo;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

/**
 * 자료실 데이터 객체 (DataVO)
 */
@Data // Lombok을 사용하면 Getter, Setter를 자동으로 생성합니다.
public class DataVO {

    private int dataNo;           // DATA_NO (일련번호)
    private int empId;          // EMP_ID (사원 ID)
    private int dataDeptCd;     // DATA_DEPT_CD (부서 코드)
    private String dataNm;         // DATA_NM (자료 제목/명칭)
    private String dataCn;         // DATA_CN (자료 내용/본문)
    private String dataType;       // DATA_TYPE (자료 유형)
    private String dataDt;         // DATA_DT (등록 일시 - String 혹은 LocalDateTime)
    private int dataCnt;           // DATA_CNT (조회수/다운로드수)
    private Long fileId;         // FILE_ID (첨부파일 ID)
    private int dataDelYn;      // DATA_DEL_YN (삭제 여부 Y/N)
    private String dataDelDt;      // DATA_DEL_DT (삭제 일시)
    private String dataShareYn;    // DATA_SHARE_YN (공유 여부 Y/N)
    private String dataShareDt;    // DATA_SHARE_DT (공유 일시)
    
    // 이전글/다음글을 위한 추가 필드
    private String prevNo;   // 이전글 번호
    private String prevTtl;  // 이전글 제목
    private String nextNo;   // 다음글 번호
    private String nextTtl;  // 다음글 제목
    private int currentPage; // 현재 페이지 번호
    private String mode;     // 검색 조건 (전체, 제목, 내용 등)
    private String keyword;  // 검색어

    // 2. 가공 및 JOIN 필드
    private String empNm;         // 작성자 이름
    private int rnum;             // 페이징용 순번
    private int fileCount;        // 첨부파일 개수
    private String fileNames;     // 첨부파일명 목록
    private boolean hasFile;      // 파일 존재 여부
    
    // 3. 파일 관련 객체
    private FileTbVO fileTbVO;
    private MultipartFile[] uploadFiles;
    private String[] delFileDtlIds; // 삭제할 파일 ID들을 담을 배열

}