package kr.or.ddit.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;

public interface CalendarService {
    
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
	
	// 일정 삭제
	public int delete(CalendarVO calendarVO);

	// 로그인한 계정의 부서명 가져오기
	public DepartmentVO getDeptNm(int empId);

	// 로그인한 계정의 팀원 출력
	List<EmployeeVO> teamList(int deptCd);

	// 연차 리스트
	public List<ApprovalVO> vacationList(Map<String, Object> map);
	
	// 출장 리스트
	public List<ApprovalVO> bztrpList(Map<String, Object> map);

	// 관리자 페이지
	public List<CalendarVO> adminList(int empId);

	public int updateAdmin(CalendarVO calendarVO);

	// 회의실 예약 리스트
	public List<ReserveVO> roomReservationList(int empId);

	// 출장/연차 카운트
	public ApprovalVO countVacation(Map<String, Object> map);
	public ApprovalVO countBizTrip(Map<String, Object> map);

	// 프로젝트 일정 리스트
	List<ProjectVO> projectCalendarList(String empId);
}
