package kr.or.ddit.vo;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;

@Data
public class ClubBoradVO {

    private int rnum;

    private int clubBbsNo;
    private int clubNo;
    private int clubMbrNo;
    private int deptCd; //부서코드
    private String clubBbsTtl;
    private String clubBbsCn;
    private int clubBbsCnt;
    private Date clubBbsDt;
    private String clubBbsStts;
    private Long clubBbsFileNo; //첨부파일 번호
    private String thumbnailPath; //썸네일 저장 경로
    private String clubBbsDclYn;

    //썸네일 이름
    private String thumbnailSaveNm;

    //동호회 이름
    private String clubNm; // 동호회 이름

    // 사진 리스트 ..
    private List<FileDetailVO> fileList;


    //직급
    private String empJbgd;
    //이름
    private String empNm;
    //부서명
    private String deptNm;

    //아바타 이름(저장명)
    private String avtSaveNm;

    //첨부파일 개수(썸네일 구석에 보여줄거임)
    private int fileCnt;


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




}
