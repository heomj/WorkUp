package kr.or.ddit.service;

import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

public interface AlarmService {


    List<EmployeeVO> getAllEmp();

    //1. 알람 테이블 등록 2. 알람 수신자 테이블 등록 (ServiceImpl에서 처리)
    int insertAlarm(AlarmVO alarmVO);

    //3.안읽은 알람 개수 구하기
    int countUnread(int empId);
    //4.안읽은 알람 목록 가져오기
    List<AlarmVO> selectAlarmList(int empId);


    List<AlarmVO> selectAllAlarmList(int empId);

    int updateStts(Map<String, Object> map);
    
    // [추가] 채팅방 전용 알람 읽음 처리 메서드
    int updateChatAlarmStts(Map<String, Object> map);
    
}
