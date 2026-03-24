package kr.or.ddit.vo;

import java.util.Date;
import java.util.List;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class NoticeVO {
    // 1. NOTICE 테이블 기본 컬럼
    private int ntcNo;            // 공지사항 번호
    private int empId;         // 작성자 사번
    private String ntcTtl;        // 제목
    private String ntcCn;         // 내용 (CLOB)
    private String ntcStts;       // 상태 (일반/긴급/중요)
    private Date ntcDt;           // 등록일시
    private int ntcCnt;           // 조회수
    private long fileId;           // 첨부파일 그룹 ID
    private String ntcDelYn;      // 삭제여부
    private Date ntcDelDt;        // 삭제일시
    private Integer ntcDeptCd;        // 부서코드
    private String ntcPopupYn;    // 팝업여부
    private Date ntcPopupBgngDt;  // 팝업시작일
    private Date ntcPopupEndDt;   // 팝업종료일
    
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
    private int fileCount;        // 첨부파일 개수 (추가)
    private String fileNames;     // 첨부파일명 목록 (추가)
    private boolean hasFile;      // 파일 존재 여부
    
    // 3. 파일 관련 객체
    private List<FileDetailVO> fileDetailVOList;
    private FileTbVO fileTbVO;
    private MultipartFile[] uploadFiles;
    private String[] delFileDtlIds; // 삭제할 파일 ID들을 담을 배열
    private List<Long> existingFileIds;
}