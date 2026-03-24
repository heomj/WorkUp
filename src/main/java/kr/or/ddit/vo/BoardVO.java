package kr.or.ddit.vo;

import java.util.Date;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class BoardVO {
	
	private int bbsNo;
	private int deptCd;
	private int empId;
	private String bbsNm;
	private String bbsCn;
	private String bbsType;
	private int bbsCnt;
	private Date bbsDt;
	private Long fileId;
	private String bbsDelYn;
	private int bbsLikeCnt;
	private boolean userLiked;
	private int resultCode;
	private int bbsDislikeCnt; // 싫어요 수
	private int bbsRecomCnt;   // 추천 수
	private boolean userDisliked; // 싫어요 여부 (추가하게나)
	private boolean userRecomed;  // 추천 여부 (추가하게나)
	private int replyCount;
	private int bbsReportCnt;	// 신고 누적 횟수
	
	// 이전글/다음글을 위한 추가 필드
    private String prevNo;   // 이전글 번호
    private String prevTtl;  // 이전글 제목
    private String nextNo;   // 다음글 번호
    private String nextTtl;  // 다음글 제목
    private int currentPage; // 현재 페이지 번호
    private String mode;     // 검색 조건 (전체, 제목, 내용 등)
    private String keyword;  // 검색어
    
    // 2. 가공 및 JOIN 필드
    private int rnum;             // 페이징용 순번
    private int fileCount;        // 첨부파일 개수
    private String fileNames;     // 첨부파일명 목록
    private boolean hasFile;      // 파일 존재 여부
    
    // 3. 파일 관련 객체
    private FileTbVO fileTbVO;
    private MultipartFile[] uploadFiles;
    private String[] delFileDtlIds; // 삭제할 파일 ID들을 담을 배열
    
    private DepartmentVO departmentVO;	//부서 객체를 통째로 포함
    private List<CommentVO> commentVOList;
    private EmployeeVO employeeVO;
}
