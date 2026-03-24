package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.AlarmMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.vo.AlarmReceiveVO;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmailReceiverVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import jakarta.annotation.Resource;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class AlarmServiceImpl implements AlarmService {

    @Autowired
    private AlarmMapper alarmMapper;
    
    @Autowired
    private SqlSession sqlSession;

    @Override
    public List<EmployeeVO> getAllEmp() {
        return this.alarmMapper.getAllEmp();
    }

    //1. 알람 테이블 등록 2. 알람 수신자 테이블 등록 (ServiceImpl에서 처리)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    @Override
    public int insertAlarm(AlarmVO alarmVO) {
        int res=0;

        if(alarmVO.getAlmRcvrNos().isEmpty()){return res;}

        res = this.alarmMapper.insertAlarm(alarmVO);

        //알람 수신자 테이블 추가하기
        List<AlarmReceiveVO> alarmReceiveVOList = new ArrayList<AlarmReceiveVO>();
        List<Integer> almRcvrNos=alarmVO.getAlmRcvrNos();
        for(Integer almRcvrNo : almRcvrNos ) {
            AlarmReceiveVO alarmReceiveVO = new AlarmReceiveVO();
            alarmReceiveVO.setEmpId(almRcvrNo);
            alarmReceiveVO.setAlmId(alarmVO.getAlmId());

            res += this.alarmMapper.insertAlarmReceive(alarmReceiveVO);
        }

        return res;
    }


    //3.안읽은 알람 개수 구하기
    @Override
    public int countUnread(int empId) {
        return this.alarmMapper.countUnread(empId);
    }
    //4.안읽은 알람 목록 가져오기
    @Override
    public List<AlarmVO> selectAlarmList(int empId) {
        return this.alarmMapper.selectAlarmList(empId);
    }

    @Override
    public List<AlarmVO> selectAllAlarmList(int empId) {
        return this.alarmMapper.selectAllAlarmList(empId);
    }

    //알람 상태 업데이트
    @Override
    public int updateStts(Map<String, Object> map) {

        String updateStts = String.valueOf(map.get("updateStts"));

        log.info("서비스임플입니다.->updateStts : {}",updateStts);
        String almRcvrNostr = String.valueOf(map.get("almRcvrNo"));
        int almRcvrNo = Integer.valueOf(almRcvrNostr);
        log.info("서비스임플입니다.->almRcvrNostr : {}",almRcvrNostr);
        if("readAllAlarm".equals(updateStts)){
            log.info("### 디버그111: 첫 번째 인자 값 -> {}", "kr.or.ddit.mapper.AlarmMapper.readAllAlarm");
            log.info("### 디버그111: 두 번째 인자 값 -> {}", almRcvrNo);
            int empId=almRcvrNo;
            return sqlSession.update("kr.or.ddit.mapper.AlarmMapper.readAllAlarm", empId);
        }else if("deleteAllAlarm".equals(updateStts)){
            log.info("### 디버그222: 첫 번째 인자 값 -> {}", "kr.or.ddit.mapper.AlarmMapper.readAllAlarm");
            log.info("### 디버그222: 두 번째 인자 값 -> {}", almRcvrNo);
            int empId=almRcvrNo;
            return sqlSession.update("kr.or.ddit.mapper.AlarmMapper.deleteAllAlarm", empId);
        }else{
            log.info("### 디버그333: 첫 번째 인자 값 -> {}", "kr.or.ddit.mapper.AlarmMapper.readAllAlarm");
            log.info("### 디버그333: 두 번째 인자 값 -> {}", almRcvrNo);
            log.info("### 디버그: updateStts 값은 [{}] 입니다.", updateStts);
            log.info("### 디버그: updateStts 길이(length)는 {} 입니다.", updateStts.length());
            return sqlSession.update(updateStts, almRcvrNo);
        }
    }
    
    @Override
    public int updateChatAlarmStts(Map<String, Object> map) {
        log.info("🚀 Service에서 Mapper 호출 전 map 데이터 확인: {}", map);
        
        // sqlSession.update() 대신 선언된 Mapper 인터페이스를 직접 호출하세요.
        // 이렇게 하면 MyBatis가 ID를 헷갈릴 일이 없습니다.
        return this.alarmMapper.readChatAlarm(map); 
    }
    
}
