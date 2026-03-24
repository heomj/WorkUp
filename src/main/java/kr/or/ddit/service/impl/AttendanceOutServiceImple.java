package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.AttendanceOutMapper;
import kr.or.ddit.service.AttendanceOutService;
import kr.or.ddit.vo.AttendanceOutVO;
import kr.or.ddit.vo.AttendanceWorkStatusVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class AttendanceOutServiceImple implements AttendanceOutService {
    @Autowired
    private AttendanceOutMapper attendanceOutMapper;

    //외출시작
    @Transactional
    @Override
    public int startOuting(AttendanceOutVO outVO) {

        // 1. 외출 테이블에 기록 꽂기
        int result = this.attendanceOutMapper.startOuting(outVO);

        // 2. 현재 근무 상태 테이블 업데이트 🦾
        if(result > 0) {
            AttendanceWorkStatusVO workStatusVO = new AttendanceWorkStatusVO();
            workStatusVO.setEmpId(outVO.getEmpId());
            int result2 = attendanceOutMapper.updateWorkStatusOut(workStatusVO.getEmpId());
            return result2;
        }
        return 0;
    }
    //외출복귀
    @Override
    public int endOuting(AttendanceOutVO outVO) {

        int result = this.attendanceOutMapper.endOuting(outVO);

        // 2. 현재 근무 상태 테이블 업데이트 🦾
        if(result > 0) {
            AttendanceWorkStatusVO workStatusVO = new AttendanceWorkStatusVO();
            workStatusVO.setEmpId(outVO.getEmpId());
            int result2 = attendanceOutMapper.updateWorkStatusBack(workStatusVO.getEmpId());
            return result2;
        }
        return 0;
    }

    //외출수정(관리자)
    @Override
    public int updateAttendance(AttendanceOutVO attendanceOutVO) {
        return this.attendanceOutMapper.updateAttendance(attendanceOutVO);
    }

    //외출삭제(관리자)
    @Override
    public int deleteAttendance(AttendanceOutVO attendanceOutVO) {
        return this.attendanceOutMapper.deleteAttendance(attendanceOutVO);
    }
}
