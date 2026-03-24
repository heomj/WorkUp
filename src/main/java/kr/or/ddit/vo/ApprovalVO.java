package kr.or.ddit.vo;


import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;

@Data
public class ApprovalVO {

    private int rnum;
    private int aprvNo;        // APRV_NO: 결재 번호 (PK)
    private int empId;         // EMP_ID: 사원 번호 (기안자)
    private String aprvSe;      // APRV_SE: 결재 구분
    private int aprvDocNo;     // APRV_DOC_NO: 결재 문서 번호
    private String aprvTtl;     // APRV_TTL: 결재 제목
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date aprvDt; // APRV_DT: 기안 일시
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date aprvEndDt; // 결재종료일
    private String aprvEmrgYn;  // APRV_EMRG_YN: 긴급 여부
    private String aprvRlsYn;   // APRV_RLS_YN: 공개 여부
    private int aprvStp;        // APRV_STP: 현재 결재 단계 (기본값 0)
    private String aprvStts;    // APRV_STTS: 결재 상태
    private String aprvDelYn;   // APRV_DEL_YN: 삭제 여부
    private Long aprvData;      // APRV_DATA 첨부파일 ID
    private int aprvLnCnt;      // APRV_LN_CNT: 전체 결재선 수 (기본값 0)

    private int aprvDeptCd; //결재문서 부서코드

    private String aprvWorkTag; //결재문서 업무 태그


    private String aprvWorkTagNm; //결재문서 업무 태그의 이름(프로젝트 명)








    private int docWriterId; //문서작성자 아이디
    private String docWriterNm; //문서작성자 이름
    private String posNm; //문서작성자 직급
    private String docWriterDeptNm; //문서작성자 부서


    private String docWriterEmpSign; //문서작성자 사인
    private String docWriterEmpProfile; //문서작성자 프로필


    //결재선 리스트..
    private List<AprvLineVO> aprvLineVOList;


    private int aprvId; //결재자 아이디


    //(관리자)
    private String deptFilter; //검색 필터(부서코드)

    //(관리자)
    private String statusFilter; //검색 필터(상태코드)

    //페이지 번호
    private int currentPage;

    //검색 모드
    private String mode;

    //검색어
    private String keyword;

    private String url; //요청URL

    //파일 업로드를 위한..
    private MultipartFile[] multipartFiles;

    //파일 다운로드를 위한..
    private FileTbVO fileTbVO;  //첨부파일 분류


/* ===========================================================
   양식별 상세 컬럼 통합 (7개 테이블)
   =========================================================== */

    // 1. 공통 및 근태 관련 (출장, 연장근무, 휴가 공통 포함)
    private int attTypeId;        // ATT_TYPE_ID (근태유형ID)

    // 2. 출장신청서 (APRV_BZTRP_DOC)
    private String bztrpPlc;         // BZTRP_PLC (출장지)
    private Date bztrpStart;       // BZTRP_START (출장 시작일)
    private Date bztrpEnd;         // BZTRP_END (출장 종료일)
    private String bztrpRsn;         // BZTRP_RSN (출장 사유)
    private String bztrpAprvYn;      // BZTRP_APRV_YN (출장 승인 여부)
    private String bztrpStts;        // BZTRP_STTS (출장 상태)

    // 3. 연장근무신청서 (APRV_EXCS_WORK_DOC)
    private Date excsWorkDocBgng;  // EXCS_WORK_DOC_BGNG (연장근무 시작시간)
    private Date excsWorkDocEnd;   // EXCS_WORK_DOC_END (연장근무 종료시간)
    private String excsWorkDocRes;   // EXCS_WORK_DOC_RES (연장근무 사유)
    private String excsWorkAprvYn;   // EXCS_WORK_APRV_YN (연장근무 승인여부)
    private String excsWorkStts;     // EXCS_WORK_STTS (연장근무 상태)


    // 4. 지출결의서 VO수정!
    private int expndDocNo;          // 신청번호 (마스터 PK)
    private String expndSttsYn;      // 삭제여부

    //다중 지출 내역을 받기 위한 리스트 필드 추가............
    // 변수명을 JSP에서 보낸 이름(expndDocList)과 반드시 맞춰야 합니다.
    private List<ExpndDocVO> expndDocList;



    // 5. 일반결재문서 (APRV_NOMAL_DOC)
    private int nmlDocNo;         // NML_DOC_NO (일반결재번호)
    private String nmlCn;            // NML_CN (일반결재내용)
    private String nmlSttsYn;        // NML_STTS_YN (일반결재상태여부)

    // 6. 보고서 (APRV_RPT_DOC)
    private int rptDocNo;         // RPT_DOC_NO (보고서번호)
    private String rptSe;            // RPT_SE (보고구분)
    private String rptCn;            // RPT_CN (보고내용)
    private String rptSttsYn;        // RPT_STTS_YN (보고상태여부)

    // 7. 사직서 (APRV_RSGNTN_DOC)
    private int rsgntnDocNo;      // RSGNTN_DOC_NO (사직서번호)
    private Date rsgntnDt;         // RSGNTN_DT (사직일자)
    private String rsgntnRsn;        // RSGNTN_RSN (사직사유)
    private String rsgntnSttsYn;     // RSGNTN_STTS_YN (사직상태여부)

    // 8. 휴가신청서 (APRV_VCT_DOC)
    private String vctDocCd;         // VCT_DOC_CD (휴가구분코드)

    //@JsonFormat 을 추가 (한국 시간으로, 이 모양 그대로 보내라고 지정)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date vctDocBgng;       // VCT_DOC_BGNG (휴가시작일)

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date vctDocEnd;        // VCT_DOC_END (휴가종료일)

    private String vctDocRsn;        // VCT_DOC_RSN (휴가사유)
    private String vctAprvYn;        // VCT_APRV_YN (휴가승인여부)
    private String vctStts;          // VCT_STTS (휴가상태)

    private double vctTotalDays; //휴가 사용일(DB 변수랑 맞춤)


    //결재 회수를 위한 휴가 여부, 근태 여부 받기
    private String isVctDoc;
    private String isAttDoc;





    // 일정 - 출장/연차 카운트용 변수
    private int monthCount; // 당월 건수
    private int totalCount; // 누적 건수
    private int maxLeave;   // 총 연차(사원 테이블 정보)

}
