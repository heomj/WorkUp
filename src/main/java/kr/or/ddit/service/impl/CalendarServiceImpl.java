package kr.or.ddit.service.impl;

import java.io.Console;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import kr.or.ddit.vo.*;

import kr.or.ddit.vo.project.ProjectVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.mapper.CalendarMapper;
import kr.or.ddit.mapper.DepartmentMapper;
import kr.or.ddit.service.CalendarService;
import kr.or.ddit.util.ArticlePage;
import kr.or.ddit.util.UploadController;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CalendarServiceImpl implements CalendarService{

    @Autowired
    CalendarMapper calendarMapper;

    @Autowired
    UploadController uploadController;


    @Autowired
    DepartmentMapper departmentMapper;

    // 조회
	@Override
	public List<CalendarVO> list(int empId) {
		return this.calendarMapper.list(empId);
	}

	// 드래그 앤 드롭 일정 수정
	@Override
	public int updateRange(CalendarVO calendarVO) {
		return this.calendarMapper.updateRange(calendarVO);
	}

	// 상세보기
	@Override
	public CalendarVO detail(int calNo) {
		 CalendarVO calendarVO = this.calendarMapper.detail(calNo);
		
		 if(calendarVO != null && calendarVO.getFileId() > 0) {
			List<FileDetailVO> fileList = this.calendarMapper.fileDetails(calendarVO.getFileId());
			calendarVO.setFileDetailVOList(fileList);
		}
		return calendarVO;
	}

	
	
	// 일정 추가
	@Transactional
    @Override
    public int addSchedule(CalendarVO calendarVO) {
		// 1. 첨부파일
		MultipartFile[] files = calendarVO.getMultipartFiles();
	    if (files != null && files.length > 0 && !files[0].getOriginalFilename().isEmpty()) {
	        FileTbVO fileTbVO = new FileTbVO();
	        fileTbVO.setEmpId(calendarVO.getEmpId());
	        fileTbVO.setFileStts("CALENDAR");
	        
	        // 파일 업로드 후 생성된 fileId를 VO에 세팅
	        Long newFileId = this.uploadController.multiFileUpload(files, fileTbVO);
	        calendarVO.setFileId(newFileId); 
	    }

	    // INSERT
	    int result = calendarMapper.addSchedule(calendarVO);
	    
	    // 3. 저장된 calNo를 가져와 공유 대상자 처리
	    int calNo = calendarVO.getCalNo();
	    List<CalendarShareVO> shareList = calendarVO.getCalendarShareList();
		

		// 4. 전체 공유인 경우 (JS에서 ALL로 보냈을 때)
		if ("Y".equals(calendarVO.getCalShare()) && (shareList == null || shareList.isEmpty())) {
			List<EmployeeVO> allEmployees = departmentMapper.getAllEmpList();
			shareList = new ArrayList<>();
			for (EmployeeVO emp : allEmployees) {
				CalendarShareVO vo = new CalendarShareVO();
				vo.setCalShareNo(calNo);
				vo.setCalShareId(emp.getEmpId());
				vo.setDeptCd(emp.getDeptCd());
				vo.setCalShareNm(emp.getEmpNm());
				if (emp.getDepartmentVO() != null) {
					vo.setCalShareDeptNm(emp.getDepartmentVO().getDeptNm());
				}
				vo.setCalShareType("전체");
				shareList.add(vo);
			}
		}
		// 5. 개별 또는 부서 공유인 경우
		else if (shareList != null && !shareList.isEmpty()) {
			for (CalendarShareVO share : shareList) {
				share.setCalShareNo(calNo);
				EmployeeVO empInfo = departmentMapper.getEmpDetail(share.getCalShareId());
				if (empInfo != null) {
					share.setCalShareNm(empInfo.getEmpNm());
					if (empInfo.getDepartmentVO() != null) {
						share.setCalShareDeptNm(empInfo.getDepartmentVO().getDeptNm());
					}
					share.setDeptCd(empInfo.getDeptCd());
				}
			}
		}

		// 6. 공유 테이블에 저장
		if (shareList != null && !shareList.isEmpty()) {
			calendarMapper.addShare(shareList);
		}    
	    return result;
    }
		
		

	// 일정 수정
	@Transactional 
	@Override
	public int update(CalendarVO calendarVO) {
		log.info("공유자리스트: {}", calendarVO.getCalendarShareList());
		
		MultipartFile[] files = calendarVO.getMultipartFiles();
	    if (files != null && files.length > 0 && !files[0].getOriginalFilename().isEmpty()) {
	        FileTbVO fileTbVO = new FileTbVO();
	        fileTbVO.setEmpId(calendarVO.getEmpId());
	        fileTbVO.setFileStts("CALENDAR");
	        
	        // 파일 업로드 후 생성된 fileId를 VO에 바로 세팅
	        Long newFileId = this.uploadController.multiFileUpload(files, fileTbVO);
	        calendarVO.setFileId(newFileId); 
	    }else {
	    }
	    int result = calendarMapper.update(calendarVO);

	    // 기존 공유 대상자 삭제
	    calendarMapper.deleteShare(calendarVO.getCalNo());
	    log.info("deleteShare : {}", calendarVO);

	    // 새로운 공유 대상자 리스트 삽입
	    List<CalendarShareVO> shareList = calendarVO.getCalendarShareList();
	    if (shareList != null && !shareList.isEmpty()) {
	        for (CalendarShareVO share : shareList) {
	        	share.setCalShareNo(calendarVO.getCalNo());
	        }
	        calendarMapper.addShare(shareList);
	        log.info("addShare : ", shareList);
	    }
	    return result;
	}

	
	// 일정 삭제
	@Transactional
	@Override
	public int delete(CalendarVO calendarVO) {
		calendarMapper.deleteShare(calendarVO.getCalNo());
		int result = calendarMapper.delete(calendarVO);
		if (result > 0) {
			log.info("일정 및 공유 정보 삭제 성공 : {}", calendarVO.getCalNo());
		}
	    return result;
	}


	// 로그인한 계정의 부서명 가져오기
	@Override
	public DepartmentVO getDeptNm(int empId) {
		return this.calendarMapper.getDeptNm(empId);
	}

	// 로그인한 계정의 팀원 출력
	@Override
	public List<EmployeeVO> teamList(int deptCd) {
		return this.calendarMapper.teamList(deptCd);
	}

	// 연차 리스트
	@Override
	public List<ApprovalVO> vacationList(Map<String, Object> map) {
		return this.calendarMapper.vacationList(map);
	}

	// 출장 리스트
	@Override
	public List<ApprovalVO> bztrpList(Map<String, Object> map) {
		return this.calendarMapper.bztrpList(map);
	}

	// 출장/연차 카운트
	@Override
	public ApprovalVO countVacation(Map<String, Object> map) {
		return this.calendarMapper.countVacation(map);
	}

	@Override
	public ApprovalVO countBizTrip(Map<String, Object> map) {
		return this.calendarMapper.countBizTrip(map);
	}

	// 프로젝트 일정 리스트
	@Override
	public List<ProjectVO> projectCalendarList(String empId) {
		return this.calendarMapper.projectCalendarList(empId);
	}


	// 관리자 페이지
	@Override
	public List<CalendarVO> adminList(int empId) {
	    List<CalendarVO> adminScheduleList = this.calendarMapper.adminList(empId);
	    
	    if (adminScheduleList == null) {
	        return new ArrayList<>();
	    }
	    
	    return adminScheduleList;
	}

	@Override
	public int updateAdmin(CalendarVO calendarVO) {
		return this.calendarMapper.updateAdmin(calendarVO);
	}

	// 회의실 예약 리스트
	@Override
	public List<ReserveVO> roomReservationList(int empId) {
		return this.calendarMapper.roomReservationList(empId);
	}


}
