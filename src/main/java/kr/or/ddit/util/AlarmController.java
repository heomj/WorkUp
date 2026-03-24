package kr.or.ddit.util;

import kr.or.ddit.mapper.AlarmMapper;
import kr.or.ddit.service.AlarmService;
import kr.or.ddit.service.impl.CustomUser;
import kr.or.ddit.vo.AlarmReceiveVO;
import kr.or.ddit.vo.AlarmVO;
import kr.or.ddit.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static kotlin.reflect.jvm.internal.impl.builtins.StandardNames.FqNames.map;

@Slf4j
@Controller
public class AlarmController {

    @Autowired
    private SimpMessagingTemplate template;
    @Autowired
    private AlarmService alarmService;
    
    @Autowired
    private AlarmMapper alarmMapper;

    // 알람 보내는 메서드 (기본 - 파라미터 4개)
    public String sendAlarm( int empId, AlarmVO alarmVO, String almUrl, String almType) {

        log.info("sendAlarm->empId : {}", empId);
        alarmVO.setEmpId(empId);
        log.info("sendAlarm->almUrl : {}", almUrl);
        alarmVO.setAlmUrl(almUrl);
        log.info("sendAlarm->almType : {}", almType);
        alarmVO.setAlmType(almType);

            if(alarmVO.getAlmRcvrNos().size()==0){
                log.info("알림 수신인이 없습니다.");  return "FAILED";
                }
            else if(alarmVO.getAlmRcvrNos().size()>0) {
                // 알람 , 알람 수신자 테이블 DB에 등록 (ServiceImpl에서 처리)
                int result = this.alarmService.insertAlarm(alarmVO);
                log.info("alarmLogic->result : {}", result);

                // 알람 보내기! (포문 돌리기)
                List<AlarmReceiveVO> alarmReceiveVOList = new ArrayList<AlarmReceiveVO>();
                for (int almRcvrNo : alarmVO.getAlmRcvrNos()) {
                    this.template.convertAndSend("/sub/alarm/" + almRcvrNo, alarmVO);
                }
                if (alarmVO.getAlmRcvrNo() !=0){
                    this.template.convertAndSend("/sub/alarm/" + alarmVO.getAlmRcvrNo(), alarmVO);
                }
            }
        return "SUCESS";
    }

    // 알람 보내는 메서드 ("수신자"님께 - 파라미터 5개)
    public String sendToAlarm( int empId, AlarmVO alarmVO, String almUrl, String almType, String to) {

        log.info("sendAlarm->empId : {}", empId);
        alarmVO.setEmpId(empId);
        log.info("sendAlarm->almUrl : {}", almUrl);
        alarmVO.setAlmUrl(almUrl);
        log.info("sendAlarm->almType : {}", almType);
        alarmVO.setAlmType(almType);

        if(alarmVO.getAlmRcvrNos().size()==0){
            log.info("알림 수신인이 없습니다."); return "FAILED";
        }
        else if(alarmVO.getAlmRcvrNos().size()>0) {
            //알람 VO리스트 만들기
            List<AlarmVO> alarmVOList = new ArrayList<>();
            AlarmReceiveVO alarmReceiveVO = new AlarmReceiveVO();
            int result = this.alarmService.insertAlarm(alarmVO);

            for (int almRcvrNo : alarmVO.getAlmRcvrNos()) {
                if("to".equals(to)) {
                    //to로 조합 만들어서 알람만 보내기
                    alarmVO.setAlmMsg(almRcvrNo+"님"+alarmVO.getAlmMsg());
                    this.template.convertAndSend("/sub/alarm/" + almRcvrNo, alarmVO);
                }
                /// /이후는 to 워딩으로 구분하여 공통메시지 커스텀하기
            }
        }
        return "SUCESS";
    }


/* AI버튼 테스트중   @GetMapping("/testaipannel")
    public String testaipannel(Model model){
        model.addAttribute("contentPage", "/CustomJSP");
        return "main";
    }*/
    /**
     *
     * 설명입니다
     * @param model
     * @return
     */
    @GetMapping("/alarm/test")
    public String alarmHome(Model model){
        model.addAttribute("contentPage", "alarm/home");
        return "main";
    }

    @GetMapping("/alarmDepTest")
    public String alarmDepTest(Model model){
        model.addAttribute("contentPage", "alarm/alarmdepTest");
        return "main";
    }

    @ResponseBody
    @PostMapping("alarm/sendtest")
    public String sendUtiltest(
            @RequestBody AlarmVO alarmVO, Authentication auth
    ){
        // 1. 사용자 정보 가져오기 : private int empId;      //보낸사람
        if(auth==null){return null;}
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId =employeeVO.getEmpId();

        String res =this.sendAlarm(empId, alarmVO, "/alarm/test", "알람");

        if("SUCESS".equals(res)){
            return "SUCESS";
        }else {return "FAILED";}
    }
    //TO 기능 확인 존
    @ResponseBody
    @PostMapping("alarm/sendtest2")
    public String sendUtiltest2(
            @RequestBody AlarmVO alarmVO, Authentication auth
    ){
        // 1. 사용자 정보 가져오기 : private int empId;      //보낸사람
        if(auth==null){return null;}
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId =employeeVO.getEmpId();

        String res =this.sendToAlarm(empId, alarmVO, "/alarm/test", "알람", "to");

        if("SUCESS".equals(res)){
            return "SUCESS";
        }else {return "FAILED";}
    }

    @ResponseBody
    @PostMapping("/alarm/unread")
    public List<AlarmVO> getUnreadAlarms(Authentication auth, AlarmVO alarmVO
    ){
        // 1. 사용자 정보 가져오기 : private int empId;      //보낸사람
        if(auth==null){return null;}
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId =employeeVO.getEmpId();

        //4.안읽은 알람 목록 가져오기
        //public List<AlarmVO> alarmVOList
        List<AlarmVO> alarmVOList = this.alarmService.selectAlarmList(empId);
        log.info("alarmLogic->alarmVOList : {}", alarmVOList);

        return  alarmVOList;
    }

    //[알림 읽음,삭제 처리]
    @ResponseBody
    @PostMapping("/alarm/updateStts")
    public int updateStts(@RequestBody Map<String,Object> map){
        log.info("updateStts->map : {}",map);
        String updateStts = String.valueOf(map.get("updateStts"));
        log.info("updateStts->updateStts : {}",updateStts);
        String almRcvrNostr = String.valueOf(map.get("almRcvrNo"));
        log.info("updateStts->almRcvrNostr : {}",almRcvrNostr);
        int almRcvrNo = Integer.valueOf(almRcvrNostr);
        int res=0;
        res = this.alarmService.updateStts(map);
        return res;
    }

    //[전체 알림 읽음,삭제 처리]
    @ResponseBody
    @PostMapping("/alarm/updateAllStts")
    public ResponseEntity<?> updateAllStts(@RequestBody Map<String,Object> map, Authentication auth){

        log.info("updateAllStts->updateAllStts : {}",map);

        //로그인한 사원아이디추출
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();

        map.put("almRcvrNo",employeeVO.getEmpId());
        log.info("updateAllStts->map : {}",map);
        try {
                int result = alarmService.updateStts(map);

            log.info("updateAllStts->result : {}",result);
            if (result > 0) {
                // 성공 시 200 OK와 함께 결과값 전달
                return ResponseEntity.ok(result);
            } else {
                // 로직상 실패 시 400 Bad Request 등 전달
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("전송 실패");
            }
        } catch (Exception e) {
            // 서버 에러 발생 시 500 Internal Server Error 전달
            log.error("알람 처리 중 에러 발생: ", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("서버 오류 발생");
        }
    }


    //알람 리스트 페이지
    @GetMapping("/alarm/list")
    public String alarmList(Model model, Authentication auth){

        if(auth==null){return null;}
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        EmployeeVO employeeVO = customUser.getEmpVO();
        int empId =employeeVO.getEmpId();

        //4.안읽은 알람 목록 가져오기
        //public List<AlarmVO> alarmVOList
        List<AlarmVO> alarmVOList = this.alarmService.selectAllAlarmList(empId);
        log.info("alarmLogic->alarmVOList : {}", alarmVOList);


        model.addAttribute("contentPage", "alarm/alarmList");
        model.addAttribute("alarmVOList", alarmVOList);
        return "main";
    }
    
    @PostMapping("/alarm/updateChatStts") 
    @ResponseBody
    public int updateChatStts(@RequestBody Map<String, Object> map, Authentication auth) {
        log.info("📡 [알람 업데이트 요청 수신] 데이터: {}", map);
        
        // 사번 강제 보정 (세션 우선)
        if (auth != null) {
            CustomUser customUser = (CustomUser) auth.getPrincipal();
            map.put("empId", customUser.getEmpVO().getEmpId());
        }

        // 🚩 JS에서 넘겨준 chatRmNo가 map에 잘 들어있는지 로그로 꼭 확인하세요!
        log.info("📡 [최종 파라미터] 사번: {}, 방번호: {}", map.get("empId"), map.get("chatRmNo"));
        
        return alarmMapper.readChatAlarm(map);
    }
    
    // [추가] 실시간 배지 갱신을 위해 안 읽은 알람 개수만 반환
    @ResponseBody
    @GetMapping("/alarm/getUnreadCount")
    public int getUnreadCount(Authentication auth) {
        if (auth == null) return 0;
        
        CustomUser customUser = (CustomUser) auth.getPrincipal();
        int empId = customUser.getEmpVO().getEmpId();

        // 기존 서비스의 selectAlarmList를 활용해 개수를 파악합니다.
        List<AlarmVO> alarmVOList = this.alarmService.selectAlarmList(empId);
        int count = (alarmVOList != null) ? alarmVOList.size() : 0;
        
        log.info("🔔 [실시간 개수 조회] 사번: {}, 개수: {}", empId, count);
        return count;
    }
}
