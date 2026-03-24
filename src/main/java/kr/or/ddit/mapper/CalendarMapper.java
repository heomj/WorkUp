package kr.or.ddit.mapper;

import java.util.List;
import java.util.Map;

import kr.or.ddit.vo.*;

import kr.or.ddit.vo.project.ProjectVO;
import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.util.ArticlePage;

@Mapper
public interface CalendarMapper {

	// 조회
	public List<CalendarVO> list(int empId);
	
	// 드래그 앤 드롭 일정 수정
	public int updateRange(CalendarVO calendarVO);
	
	// 상세보기
	public CalendarVO detail(int calNo);
	
	// 일정 추가
	public int addSchedule(CalendarVO calendarVO);
	
	// 일정 수정
	public int update(CalendarVO calendarVO);

	// 일정 추가 - 공유 대상 선택
	public void addShare(List<CalendarShareVO> shareList);

	// 일정 수정 - 기존 공유 대상자 삭제
	public void deleteShare(int calNo);

	// 일정 수정 - 새로운 공유 대상자 리스트가 있다면 다시 삽입
	public void insertCalendarShareList(List<CalendarShareVO> shareList);
	
	// 일정 삭제
	public int delete(CalendarVO calendarVO);

	// 로그인한 계정의 부서명 가져오기
	public DepartmentVO getDeptNm(int empId);

	// 로그인한 계정의 팀원 출력
	List<EmployeeVO> teamList(int deptCd);

	// 첨부파일 list 가져오기
	public List<FileDetailVO> fileDetails(long fileId);
	
	// 연차 리스트
	public List<ApprovalVO> vacationList(Map<String, Object> map);
	
	// 출장 리스트
	public List<ApprovalVO> bztrpList(Map<String, Object> map);

	// 프로젝트 일정 리스트
	public List<ProjectVO> projectCalendarList(String empId);


	
	// 관리자 페이지
	public List<CalendarVO> adminList(int empId);

	public int updateAdmin(CalendarVO calendarVO);

	// 회의실 예약 리스트
	public List<ReserveVO> roomReservationList(int empId);

	// 출장/연차 카운트
	public ApprovalVO countVacation(Map<String, Object> map);
	public ApprovalVO countBizTrip(Map<String, Object> map);
}
