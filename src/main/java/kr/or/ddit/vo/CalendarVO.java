package kr.or.ddit.vo;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.Data;

@Data
public class CalendarVO {
	private int calNo;
	private int empId;
	private String calTtl;
	private String calCn;
	private String calBgngDt;
	private String calEndDt;
	private String calColor;
	private long fileId;
	private String calDt;			// 일정 작성일
	private String calUpdate;		// 일정 수정일
	private String calImportant;	// 중요한 일정 : 1, 중요하지 않은 일정 : 0
	private String calLocation;
	private String calStts;			// 일정 삭제 : N, 출력 : Y
	private String calBgngTm;
	private String calEndTm;
	private String calShare;		// 일정 공유 여부
	private String calAllday;		// 종일 일정 여부
	private String calHolidayYn;	// 휴일 여부
	
    
    
    private int rnum;

	private int deptCd;
    private List<CalendarShareVO> calendarShareList;
    
    @JsonIgnore
    private MultipartFile[] multipartFiles;
    
    
    //private FileVO fileVO;
    
    // 상세 파일ID
    private long fileDtlId;

    private List<FileDetailVO> fileDetailVOList;

	// 회의실 예약 일정 구분용
	private ReserveVO reserve;
	private String isReservation;


	// 프로젝트 일정 가져오기용
	private String projStts;   // 프로젝트 상태 혹은 참여자 명단
	private String projIpt;    // 중요도
	private int projPrgrt;     // 진행률
	private String calContent; // 프로젝트 설명 (calCn과 별개로 쓰거나 공유)
}
