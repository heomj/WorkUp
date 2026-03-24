package kr.or.ddit.mapper;

import kr.or.ddit.vo.AlarmReceiveVO;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface AlarmMapper {

    List<EmployeeVO> getAllEmp();

    //1. 알람 테이블 등록
    int insertAlarm(AlarmVO alarmVO);
    //2. 알람 수신자 테이블 등록 (ServiceImpl에서 처리)
    int insertAlarmReceive(AlarmReceiveVO alarmReceiveVO);

    //3.안읽은 알람 개수 구하기
    int countUnread(int empId);

    //4.안읽은 알람 목록 가져오기
    List<AlarmVO> selectAlarmList(int empId);

    List<AlarmVO> selectAllAlarmList(int empId);
    
    // [추가] 일반 알람 읽음 처리용
    int updateStts(Map<String, Object> map);
    
    int readChatAlarm(Map<String, Object> map);
}
