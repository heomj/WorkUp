package kr.or.ddit.service;

import kr.or.ddit.vo.AttendanceOutVO;

public interface AttendanceOutService {
    // 외출시작
    public int startOuting(AttendanceOutVO outVO);

    // 외출복귀
    public int endOuting(AttendanceOutVO outVO);

    // 외출수정(관리자)
    public int updateAttendance(AttendanceOutVO attendanceOutVO);

    // 외출삭제(관리자)
    public int deleteAttendance(AttendanceOutVO attendanceOutVO);
}
