package kr.or.ddit.mapper;

import kr.or.ddit.vo.AttendanceOutVO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AttendanceOutMapper {

    // 외출시작
    public int startOuting(AttendanceOutVO outVO);
    // 외출 시 상태 업데이트
    public int updateWorkStatusOut(int empId);


    // 외출복귀
    public int endOuting(AttendanceOutVO outVO);

    // 복귀 시 상태 업데이트
    public int updateWorkStatusBack(int empId);

    // 외출수정(관리자)
    public int updateAttendance(AttendanceOutVO attendanceOutVO);

    // 외출삭제(관리자)
    public int deleteAttendance(AttendanceOutVO attendanceOutVO);
}
