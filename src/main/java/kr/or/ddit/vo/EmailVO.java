package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;

@Data
public class EmailVO {

    private int emlNo;

    private List<Integer> emlRcvrIds;   //수신자 (컬럼아님)
    private List<Integer> emlCcIds;     //참조자 (컬럼아님)

    private int emlRcvrId;              //수신자테이블 아이디-기본키 (이메일테이블 컬럼아님)
    private String emlImptYn;              //수신자테이블 중요표시
    private String emlDelYn;            //수신자테이블 삭제표시
    private String emlRcvrType;            //수신자테이블 참조자 여부

    private int emlSndrId;
    private String emlTtl;
    private String emlCn;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date emlSndngDt;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date emlRcvngDt;
    private String emlEmrgYn;
    private String emlRcptnYn; //수신자테이블 읽음여부
    private String emlSndrDelYn; //회수해서 삭제하는 경우
    private String emlOtsdYn;
    private String emlOtsdRcvrAddr;
    private String emlOtsdSndrAddr;
    private String emlStts;
    private String field;
    private Long fileId;

    private MultipartFile[] multipartFiles;

    private int rnum;//행번호
    private int currentPage;	//페이지번호
    private String mode; //검색모드
    private String keyword;//검색어
    private int pageNum;//출력 페이지 개수
    private String pageFilter;//출력 리스트 필터

    //JOIN 결과
    private String empNm; //사원 이름
    private String empProfile;  //보낸 사원의 프로필..
    private String empJbgd;  // 직급(사워, 주임, 대리, 팀장)
    private int deptCd;   //부서추가정보
    private String deptNm;     // 부서명

    private FileTbVO fileTbVO;  //첨부파일 분류

    //알람 - 안읽은 메일 수
    private int cnt;

    private String replyorforward; //답장 또는 전달을 표시하기 위해서 임의로 설정한 변수,,

    //보낸 메일함에서 수신확인 해야하니 수신자 VO리스트..
    private List<EmailReceiverVO> emailReceiverVOList;

}
